import "package:meta/meta.dart";
import "package:ella/strings/StringUtil.dart";
import "package:ella/time/EllaDate.dart";
import "package:ella/time/EllaTime.dart";
import "package:ella/time/EllaDateTime.dart";
import "package:ella/time/TwelveHourTime.dart";
import "package:ella/time/util/DateTimeSymbols.dart";

/** @fileoverview DateTimeFormatter for JClosure, somewhat simplistic.
      Does not handle timezones. Is assumed to be in local time.
      See: https://github.com/google/closure-library/blob/master/closure/goog/i18n/datetimeformat.js
*/

/**
 * Datetime formatting functions following the pattern specification as defined
 * in JDK, ICU and CLDR, with minor modification for typical usage in JS.
 * Pattern specification:
 * {@link http://userguide.icu-project.org/formatparse/datetime}
 * <pre>
 * Symbol   Meaning                    Presentation       Example
 * ------   -------                    ------------       -------
 * G#       era designator             (Text)             AD
 * y#       year                       (Number)           1996
 * Y*       year (week of year)        (Number)           1997
 * u*       extended year              (Number)           4601
 * Q#       quarter                    (Text)             Q3 & 3rd quarter
 * M        month in year              (Text & Number)    July & 07
 * L        month in year (standalone) (Text & Number)    July & 07
 * d        day in month               (Number)           10
 * h        hour in am/pm (1~12)       (Number)           12
 * H        hour in day (0~23)         (Number)           0
 * m        minute in hour             (Number)           30
 * s        second in minute           (Number)           55
 * S        fractional second          (Number)           978
 * E#       day of week                (Text)             Tue & Tuesday
 * e*       day of week (local 1~7)    (Number)           2
 * c#       day of week (standalone)   (Text & Number)    2 & Tues & Tuesday & T
 * D*       day in year                (Number)           189
 * F*       day of week in month       (Number)           2 (2nd Wed in July)
 * w        week in year               (Number)           27
 * W*       week in month              (Number)           2
 * a        am/pm marker               (Text)             PM
 * k        hour in day (1~24)         (Number)           24
 * K        hour in am/pm (0~11)       (Number)           0
 * z        time zone                  (Text)             Pacific Standard Time
 * Z#       time zone (RFC 822)        (Number)           -0800
 * v#       time zone (generic)        (Text)             America/Los_Angeles
 * V#       time zone                  (Text)             Los Angeles Time
 * g*       Julian day                 (Number)           2451334
 * A*       milliseconds in day        (Number)           69540000
 * '        escape for text            (Delimiter)        'Date='
 * ''       single quote               (Literal)          'o''clock'
 *
 * Item marked with '*' are not supported yet.
 * Item marked with '#' works different than java
 *
 * The count of pattern letters determine the format.
 * (Text): 4 or more, use full form, <4, use short or abbreviated form if it
 * exists. (e.g., "EEEE" produces "Monday", "EEE" produces "Mon")
 *
 * (Number): the minimum number of digits. Shorter numbers are zero-padded to
 * this amount (e.g. if "m" produces "6", "mm" produces "06"). Year is handled
 * specially; that is, if the count of 'y' is 2, the Year will be truncated to
 * 2 digits. (e.g., if "yyyy" produces "1997", "yy" produces "97".) Unlike other
 * fields, fractional seconds are padded on the right with zero.
 *
 * :(Text & Number) 3 or over, use text, otherwise use number. (e.g., "M"
 * produces "1", "MM" produces "01", "MMM" produces "Jan", and "MMMM" produces
 * "January".)
 *
 * Any characters in the pattern that are not in the ranges of ['a'..'z'] and
 * ['A'..'Z'] will be treated as quoted text. For instance, characters like ':',
 * '.', ' ', '#' and '@' will appear in the resulting time text even they are
 * not embraced within single quotes.
 * </pre>
 */

class _DateTimeFormatError implements Exception
{
  late String message;

  _DateTimeFormatError()
  {
    message = "Failed to parse supplied format. Check field count is supported by field formatter method.";
  }
}

// Main class
class DateTimeFormatter
{
  // Public constants for common formats.
  static const String I18N_DEFAULT_FORMAT = "MMM d, yyyy h:mm a";
  static const String I18N_FORMAT_DATE = "MMM d, yyyy";
  static const String I18N_FORMAT_DATE_SHORT = "d/M/yyyy";
  static const String I18N_FORMAT_DATE_SHORT_YANK = "M/d/yyyy";
  static const String I18N_FORMAT_DATETIME_WO_YEAR = "MMM d h:mm a";
  static const String I18N_FORMAT_DATE_WO_YEAR = "MMM d";
  static const String I18N_FORMAT_DAY_OF_WEEK_AND_DATE = "EE, d of MMM";
  static const String I18N_FORMAT_DAY_OF_WEEK_AND_DATE_YANK = "EE, MMM d";
  static const String I18N_FORMAT_DAY_OF_WEEK_SHORT = "E d MM yyyy";
  static const String I18N_FORMAT_TIME = "h:mm a";

  // Date time being formatted
  @protected late EllaDateTime dateTime;

  // Formatter output
  @protected late StringBuffer sb;

  String formatDateTime(DateTime dateTime, [String? formatString])
  {
    return format( new EllaDateTime.fromDateTime(dateTime), formatString);
  }

  String formatDate(EllaDate date, [String formatString = I18N_FORMAT_DATE])
  {
    return format( new EllaDateTime(date, EllaTime.empty), formatString);
  }

  String formatTime(EllaTime time, [String formatString = I18N_FORMAT_TIME])
  {
    return format( new EllaDateTime(EllaDate.empty, time), formatString);
  }

  String format(EllaDateTime dateTime, [String? formatString])
  {
    StringBuffer sb = new StringBuffer();
    formatIntoBuffer(sb, dateTime, formatString);
    return sb.toString();
  }

  String formatIntoBuffer(StringBuffer sb, EllaDateTime dateTime, [String? formatString])
  {
    // Apply default format string if not set.
    formatString ??= getDefaultFormatString();

    this.dateTime = dateTime;

    this.sb = sb;

    // Parse format.
    String c;
    int count; // How many in field
    for (int i=0; i < formatString.length; i++)
    {
      c = formatString[i];
      count = 0;
      // Count field (how many chars match exactly)
      while ( i + count < formatString.length && formatString[i + count] == c )
      {
        count++;
      }

      formatField(c, count);

      i += count - 1;
    }

    return sb.toString();
  }

  @protected String getDefaultFormatString()
  {
    return I18N_DEFAULT_FORMAT;
  }

  @protected void formatField(String formatChar, int count)
  {
    switch (formatChar)
    {
      // Use big-endian order of cases.
      case 'y':
        _formatYear(count);
        break;
      case 'M':
        _formatMonth(count);
        break;
     case 'd':
        _formatDayOfMonth(count);
        break;
     case 'E':
        _formatDayOfWeek(count);
        break;
     case 'h':
        _formatHours(count);
        break;
     case 'm':
        _formatMinutes(count);
        break;
     case 'a':
        _formatAmPm(count);
        break;
      default:
        // If not a command, append verbatim.
        sb.write(formatChar);
    }
  }

  void _formatYear(int count)
  {
    sb.write(dateTime.date.year);
  }

  void _formatMonth(int count)
  {
    // Incomplete support for month formatting, but sufficient for most formats.
    if (count == 1) {
      // e.g. 'M'
      sb.write( dateTime.date.month );
    }
    else if (count == 2) {
      // e.g. 'MM'
      sb.write( DateTimeSymbols.SHORTMONTHS[ dateTime.date.month-1 ] );
    }
    else if (count == 3) {
      // e.g. 'MMM'
      sb.write( DateTimeSymbols.MONTHS[ dateTime.date.month-1 ] );
    }
    else {
      new _DateTimeFormatError();
    }
  }

  void _formatDayOfMonth(int count)
  {
    sb.write( StringUtil.padNumber(dateTime.date.day, count) );
  }

  void _formatDayOfWeek(int count)
  {
    String dayOfWeek = DateTimeSymbols.DAYS_OF_WEEK_NAMES[dateTime.date.toDateTime().weekday-1];
    if (count == 1) {
      dayOfWeek = dayOfWeek.substring(0, 3); // Truncate day of week.
    }
    sb.write(dayOfWeek);
  }

  void _formatHours(int count)
  {
    TwelveHourTime model = new TwelveHourTime.fromEllaTime(dateTime.time);
    sb.write( StringUtil.padNumber(model.hours, count) );
  }

  void _formatMinutes(int count)
  {
    sb.write( StringUtil.padNumber(dateTime.time.getMinutesComponent(), count) );
  }

  void _formatAmPm(int count)
  {
    TwelveHourTime model = new TwelveHourTime.fromEllaTime(dateTime.time);
    sb.write( DateTimeSymbols.MERIDIEM_NAMES[model.meridiemMode] );
  }

  // Static convenience methods.
  static String quickFormat(EllaDateTime dateTime, [String? formatString])
  {
    return new DateTimeFormatter().format(dateTime, formatString);
  }

  static String quickFormatDate(EllaDate date, [String formatString = I18N_FORMAT_DATE])
  {
    return new DateTimeFormatter().formatDate(date, formatString);
  }

  static String quickFormatDateTime(DateTime dateTime, [String formatString = I18N_DEFAULT_FORMAT])
  {
    return new DateTimeFormatter().formatDateTime(dateTime, formatString);
  }
}

