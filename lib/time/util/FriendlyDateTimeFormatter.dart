import "package:meta/meta.dart";
import "package:ella/time/util/DateTimeFormatter.dart";

/** @fileoverview Extends DateTimeFormatter to add human-friendly relative formatting for dates near the current date via an 'F' symbol. */

class FriendlyDateTimeFormatter extends DateTimeFormatter
{
  // Set default format string to use for date (may be configured before calling format() .
  String absoluteFormatString = DateTimeFormatter.I18N_FORMAT_DAY_OF_WEEK_SHORT;

  final DateTime _now;

  FriendlyDateTimeFormatter(DateTime now):
    // In order for formatting logic to be accurate, must not consider hours/minutes component of date.
    _now = new DateTime(now.year, now.month, now.day);

  @override
  @protected String getDefaultFormatString()
  {
    return "${DateTimeFormatter.I18N_FORMAT_TIME} F";
  }

  @override
  @protected void formatField(String formatChar, int count)
  {
    switch (formatChar)
    {
      case 'F':
        _formatFriendlyTime();
        break;
      default:
        super.formatField(formatChar, count);
    }
  }

  void _formatFriendlyTime()
  {
    Duration difference = dateTime.date.toDateTime().difference(_now);

    // Provide relative formatting if supported.
    switch (difference.inDays)
    {
      case -1:
        sb.write("Yesterday");
        break;
      case 0:
        sb.write("Today");
        break;
      case 1:
        sb.write("Tomorrow");
        break;
      default:
        _formatAbsoluteTime();
        break;
    }
  }

  void _formatAbsoluteTime()
  {
    new DateTimeFormatter().formatIntoBuffer(sb, dateTime, absoluteFormatString);
  }
}
