
/** @fileoverview Constants used by time package */

abstract class TimePrecision
{
  /** This is the value divided by, which is why lower precision has a higher value. */
  static const int MONTHS = 2592000000;
  static const int WEEKS = 604800000;
  static const int DAYS = 86400000;
  static const int HOURS = 3600000;
  static const int MINUTES = 60000;
  static const int SECONDS = 1000;
  static const int MILLISECONDS = 1;

  static final List<int> values = [MONTHS, WEEKS, DAYS, HOURS, MINUTES, SECONDS, MILLISECONDS];
}
