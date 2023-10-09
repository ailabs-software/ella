import "package:ella/time/EllaTime.dart";
import "package:ella/time/MeridiemMode.dart";

/** @fileoverview Represents time in a 12 hour format, and provides conversion between 12-hour format and 24-hour format. */

class TwelveHourTime
{
  final MeridiemMode meridiemMode;
  final int hours;
  final int minutes;
  final int seconds;

  // Default constructor sets default values.
  TwelveHourTime(MeridiemMode this.meridiemMode, [int this.hours = 0, int this.minutes = 0, int this.seconds = 0]);

  static final TwelveHourTime _END_OF_DAY_TWELVE_HOUR_TIME = new TwelveHourTime(MeridiemMode.EndOfDay, 12, 0, 0);

  static final EllaTime _END_OF_DAY_SIMPLE_TIME = new EllaTime.fromComponents(24, 0, 0); // 24:00:00 converts to 0:00:00 next day in PostgreSQL RDBMS.

  factory TwelveHourTime.fromEllaTime(EllaTime value)
  {
    MeridiemMode meridiemMode;

    // Conversion to 12-hour clock.
    int hours = value.getHoursComponent();
    if (hours == 24) {
      return _END_OF_DAY_TWELVE_HOUR_TIME;
    }
    else if (hours >= 12) {
      hours -= 12;
      meridiemMode = MeridiemMode.PostMeridiem;
    }
    else {
      // Added this missing case on 10 Feb 2019.
      meridiemMode = MeridiemMode.AnteMeridiem;
    }

    if (hours == 0) {
      hours = 12; // 12 o'clock
    }

    return new TwelveHourTime(meridiemMode, hours, value.getMinutesComponent() );
  }

  EllaTime toEllaTime()
  {
    int hoursOut = hours;

    // Check for end of day first.
    if (meridiemMode == MeridiemMode.EndOfDay) {
      return _END_OF_DAY_SIMPLE_TIME;
    }

    // Conversion to 24-hour clock.
    bool isPostMeridiem = meridiemMode == MeridiemMode.PostMeridiem;
    if (isPostMeridiem && hoursOut != 12) {
      hoursOut += 12;
    }
    else if (!isPostMeridiem && hoursOut == 12) {
      hoursOut = 0;
    }

    return new EllaTime.fromComponents(hoursOut, minutes, seconds);
  }
}
