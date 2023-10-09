import "package:ella/time/MeridiemMode.dart";

/**
 * @fileoverview
 * Date/time formatting symbols for locale en_ISO.
 */

class DateTimeSymbols
{
  // constants.

  static const List<String> MONTHS =
    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  static const List<String> SHORTMONTHS =
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  static const List<String> DAYS_OF_WEEK_NAMES =
    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  static const String ANTE_MERIDIEM_NAME = "AM";

  static const String POST_MERIDIEM_NAME = "PM";

  static const Map<MeridiemMode, String> MERIDIEM_NAMES =
    {MeridiemMode.AnteMeridiem: ANTE_MERIDIEM_NAME, MeridiemMode.PostMeridiem: POST_MERIDIEM_NAME, MeridiemMode.EndOfDay: ANTE_MERIDIEM_NAME};
}
