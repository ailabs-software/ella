import "package:ella/ella.dart";
import "package:ella/time/EllaTime.dart";
import "package:ella/time/MeridiemMode.dart";
import "package:ella/time/TwelveHourTime.dart";

class TimeParser
{
  static final RegExp _REMOVE_CHARS_REGEXP = new RegExp("[^0-9:]");

  static EllaTime parse(String value)
  {
    value = value.toLowerCase();
    MeridiemMode meridiemMode = MeridiemMode.AnteMeridiem;
    if ( value.contains("pm") ) {
      meridiemMode = MeridiemMode.PostMeridiem;
    }

    // Filter out am/pm noise first!
    value = value.replaceAll(_REMOVE_CHARS_REGEXP, ella.EMPTY_STRING);

    List<String> parts;

    if ( value.contains(".") ) {
      parts = value.split(".");
    }
    else if ( value.contains(":") ) {
      parts = value.split(":");
    }
    else {
      // Split support when colon is missing.
      parts = [];
      if (value.length < 3) {
        parts.add(value); // assume entire value is the hour.
        parts.add( 0.toString() ); // minutes must be zero in this case.
      }
      else if (value.length == 3) {
        parts.add( value.substring(0, 1) );
        parts.add( value.substring(2, 3) );
      }
      else if (value.length == 4) {
        parts.add( value.substring(0, 2) );
        parts.add( value.substring(2, 4) );
      }
      else {
        throw new Exception("Bad format");
      }
    }

    // Parse hours.
    String hoursPart = parts[0];
    int hours = int.parse(hoursPart);

    // Parse minutes.
    String minutesPart = parts[1];
    int minutes = int.parse(minutesPart);

    TwelveHourTime model = new TwelveHourTime(meridiemMode, hours, minutes);

    return model.toEllaTime();
  }

  static EllaTime? tryParse(String value)
  {
    try {
      if (value.isNotEmpty) {
        return parse(value);
      }
    }
    catch(e) {
      // Forgiven & forgotten
    }
    return null;
  }
}
