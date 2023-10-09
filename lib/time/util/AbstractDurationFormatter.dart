import "package:meta/meta.dart";
import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/strings/StringJoiner.dart";
import "package:ella/time/util/TimePrecision.dart";

/** @fileoverview Duration formatter abstract class. */

abstract class AbstractDurationFormatter
{
  // Static initializer won't run until needed.
  // Order is from biggest to smallest as we will often want to show biggest first, or only biggest.
  static final List<int> precisions =
    [TimePrecision.DAYS, TimePrecision.HOURS, TimePrecision.MINUTES, TimePrecision.SECONDS];

  /** Highest precision to show (value most to right) */
  final int _highestPrecisionShown;

  /** Value to format */
  late double _durationMs;

  /** @param highestPrecisionShown -- Value shown most to right */
  AbstractDurationFormatter(int this._highestPrecisionShown);

  /** Set in milliseconds */
  AbstractDurationFormatter setDurationMillis(double ms)
  {
    if (ms != ms) {
      throw new Exception("goog.strings.AbstractDurationFormatter: Unacceptable input for duration");
    }
    _durationMs = ms;

    return this;
  }

  /** Set in seconds */
  AbstractDurationFormatter setDurationSeconds(double seconds)
  {
    setDurationMillis(seconds * 1000);

    return this;
  }

  /** Set from dart Duration object. */
  AbstractDurationFormatter setDuration(Duration duration)
  {
    setDurationMillis( duration.inMilliseconds.toDouble() );
    
    return this;
  }

  /** Runs formatter class */
  String getFormatted()
  {
    StringJoiner sj = new StringJoiner( getInterpolatorChar() );

    int lastPrecision = 0;
    for (int precision in precisions)
    {
      if ( precision >= _highestPrecisionShown ) {
        if ( formatCurrentPrecision(sj, lastPrecision, precision, _durationMs) ) {
          break; // Exit loop as instructed by virtual function.
        }
        lastPrecision = precision;
      }
      else {
        break; // Because set is ordered from largest to smallest, there won't be others we haven't already rendered.
      }
    }

    return sj.toString();
  }

  /** Optionally used helper code. Valid for DCE. */
  @protected String getUnitName(int precision)
  {
    switch (precision)
    {
      case TimePrecision.MONTHS:
        return "months";
      case TimePrecision.WEEKS:
        return "weeks";
      case TimePrecision.DAYS:
        return "days";
      case TimePrecision.HOURS:
        return "hours";
      case TimePrecision.MINUTES:
        return "minutes";
      case TimePrecision.SECONDS:
        return "seconds";
      case TimePrecision.MILLISECONDS:
        return "ms";
      default:
        throw new IllegalArgumentException();
    }
  }

  Stream<String> formatSecondsStream(Stream<double> stream) async*
  {
    await for (double secondsValue in stream)
    {
      setDurationSeconds(secondsValue);
      yield getFormatted();
    }
  }

  /** See concrete class */
  @protected String getInterpolatorChar();

  /** Return value indicates whether to stop the loop */
  @protected bool formatCurrentPrecision(StringJoiner sj, int lastPrecision, int currentPrecision, double durationMs);
}


