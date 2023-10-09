import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/strings/StringUtil.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Model can either represent a time of day or an interval */

const String _NEGATIVE_INTERVAL_PREFIX = "-";
final int _NEGATIVE_INTERVAL_PREFIX_CODE_UNIT = _NEGATIVE_INTERVAL_PREFIX.codeUnitAt(0);
const String _INTERVAL_SEGMENT_SEPARATOR = ":";
const int _INTERVAL_SEGMENT_PADDING = 2;

class EllaTime implements ISerialisable
{
  static const int secondsPerMinute = 60;

  static const int secondsPerHour = 3600;

  static const int secondsPerDay = 86400;

  static final EllaTime empty = new EllaTime(0);

  final int seconds;

  /** Default constructor which accepts total seconds. */
  EllaTime(int this.seconds);

  /** Construct from time components */
  factory EllaTime.fromComponents(int hours, int minutes, int seconds)
  {
    return new EllaTime( componentsToSeconds(hours, minutes, seconds) );
  }

  /** Construct from DateTime's time values */
  factory EllaTime.fromDateTime(DateTime dateTime)
  {
    return new EllaTime.fromComponents(dateTime.hour, dateTime.minute, dateTime.second);
  }

  /** Construct from Duration object */
  factory EllaTime.fromDuration(Duration duration)
  {
    return new EllaTime(duration.inSeconds);
  }

  /** Expects input in format of hh:mm. Does not support an offset unit greater than hours. */
  factory EllaTime.fromInterval(String value)
  {
    bool isNegative = value.codeUnitAt(0) == _NEGATIVE_INTERVAL_PREFIX_CODE_UNIT;
    List<int> segments = value.split(_INTERVAL_SEGMENT_SEPARATOR).map(int.parse).toList();
    if (segments.length != 3) {
      throw new IllegalArgumentException("Wrong number of SQL interval components.");
    }
    int hoursComponent = segments[0].abs();
    int minutesComponent = segments[1].abs();
    int seconds = EllaTime.componentsToSeconds(hoursComponent, minutesComponent, 0);
    if (isNegative) {
      seconds *= -1;
    }
    return new EllaTime(seconds);
  }

  static int componentsToSeconds(int hours, int minutes, int seconds)
  {
    return (hours * secondsPerHour) + (minutes * secondsPerMinute) + seconds;
  }

  @override
  int get hashCode
  {
    return seconds.hashCode;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is EllaTime) {
      return other.seconds == seconds;
    }
    else {
      return false;
    }
  }

  bool isNegative()
  {
    return seconds < 0;
  }

  EllaTime toAbsolute()
  {
    return new EllaTime( seconds.abs() );
  }

  int getHoursComponent()
  {
    return seconds ~/ secondsPerHour;
  }

  int getMinutesComponent()
  {
    return seconds.remainder(secondsPerHour) ~/ secondsPerMinute;
  }

  int getSecondsComponent()
  {
    return seconds.remainder(secondsPerMinute);
  }

  String toSQLInterval()
  {
    EllaTime absolute = toAbsolute();
    List<int> output = [absolute.getHoursComponent(), absolute.getMinutesComponent(), absolute.getSecondsComponent()];
    String value = output.map( (int v) => StringUtil.padNumber(v, _INTERVAL_SEGMENT_PADDING) ).join(_INTERVAL_SEGMENT_SEPARATOR);
    if ( isNegative() ) {
      return _NEGATIVE_INTERVAL_PREFIX + value;
    }
    else {
      return value;
    }
  }

  /** Returns the total minutes in the time */
  int toMinutes()
  {
    return seconds ~/ secondsPerMinute;
  }

  Duration toDuration()
  {
    return new Duration(seconds: seconds);
  }

  DateTime toDateTime(DateTime dateTime)
  {
    return new DateTime(dateTime.year, dateTime.month, dateTime.day, getHoursComponent(), getMinutesComponent(), getSecondsComponent());
  }

  EllaTime addSeconds(int value)
  {
    return new EllaTime(seconds + value);
  }

  EllaTime addMinutes(int value)
  {
    return addSeconds(value * secondsPerMinute);
  }

  EllaTime addHours(int value)
  {
    return addSeconds(value * secondsPerHour);
  }

  EllaTime addDays(int value)
  {
    return addSeconds(value * secondsPerDay);
  }

  EllaTime addDuration(Duration duration)
  {
    return addSeconds(duration.inSeconds);
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setRawValue(seconds);
  }

  /** Encoded object parameter is encoded depending on format. */
  static EllaTime unmarshal(MarshalledObject marshalled)
  {
    int seconds = marshalled.asInt();
    return new EllaTime(seconds);
  }
}
