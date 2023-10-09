import "package:meta/meta.dart";
import "package:ella/ella.dart";
import "package:ella/strings/StringJoiner.dart";
import "package:ella/time/util/AbstractDurationFormatter.dart";
import "package:ella/time/util/TimePrecision.dart";

/** @fileoverview Like LongDurationFormatter and DurationFormatter, but formatted for countdowns. */

class CountdownDurationFormatter extends AbstractDurationFormatter
{
  /** Chain super constructor -- @param highestPrecisionShown -- Value shown most to right */
  CountdownDurationFormatter(int highestPrecisionShown): super(highestPrecisionShown);

  @override
  @protected String getInterpolatorChar()
  {
    return ella.EMPTY_STRING;
  }

  @override
  @protected bool formatCurrentPrecision(StringJoiner sj, int lastPrecision, int currentPrecision, double durationMs)
  {
    // Show days or hours if at least one, otherwise skip.    
    if (currentPrecision >= TimePrecision.HOURS) {
      if (durationMs < currentPrecision) {
        return false; // Skip if not at least 1.
      }
    }

    sj.add( getDurationForPrecision(currentPrecision, durationMs).toString() );

    // Handles all.
    sj.add(" ");
    sj.add( getUnitName(currentPrecision) );
    sj.add(" ");

    return false; // Continue loop.
  }

  static int getDurationForPrecision(int precision, double durationMs)
  {
    double numerator = durationMs;

    if (precision != TimePrecision.DAYS) {
      int previousPrecision = getPreviousPrecision(precision);
      numerator = numerator % previousPrecision.toDouble();
    }

    return  ( numerator / precision.toDouble() ).floor();
  }

  static int getPreviousPrecision(int precision)
  {
    int index = TimePrecision.values.indexOf(precision);
    if (index > 0) {
      return TimePrecision.values[index - 1];
    }
    else {
      return 0;
    }
  }
}


