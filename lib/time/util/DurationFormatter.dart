import "package:meta/meta.dart";
import "package:ella/strings/StringJoiner.dart";
import "package:ella/strings/StringUtil.dart";
import "package:ella/time/util/TimePrecision.dart";
import "package:ella/time/util/AbstractDurationFormatter.dart";

/** @fileoverview Formats durations */

class DurationFormatter extends AbstractDurationFormatter
{
  static final int _PAD_VALUE = 2;

  /** Chain super constructor -- @param highestPrecisionShown -- Value shown most to right */
  DurationFormatter(int highestPrecisionShown): super(highestPrecisionShown);

  @override
  @protected String getInterpolatorChar()
  {
    return ":";
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

    double numerator = durationMs;

    if (lastPrecision != 0) {
      numerator = numerator % lastPrecision.toDouble();
    }

    // Handles all.
    sj.add( StringUtil.padNumber( ( numerator / currentPrecision.toDouble() ).floor().toDouble(), _PAD_VALUE) );

    return false; // Always continue loop.
  }
}


