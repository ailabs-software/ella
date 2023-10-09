import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Range.dart";
import "package:ella/time/EllaTime.dart";

/** @fileoverview Time range model */

class EllaTimeRange implements ISerialisable
{
  final EllaTime begin;

  final EllaTime end;

  EllaTimeRange(EllaTime this.begin, EllaTime this.end);

  bool overlapsAny(Iterable<EllaTimeRange> timeRanges)
  {
    return timeRanges.any( (EllaTimeRange m) => overlaps(m) );
  }

  bool overlaps(EllaTimeRange other)
  {
    return toRange().overlaps( other.toRange() );
  }

  Range toRange()
  {
    return new Range(begin.seconds, end.seconds);
  }

  bool isValid()
  {
    return begin.seconds < end.seconds;
  }

  EllaTime elapsedTime()
  {
    return new EllaTime(end.seconds - begin.seconds);
  }

  // Returns ranges list where every gap in input range list
  // is a range in the output list.
  static Iterable<EllaTimeRange> invertRangesList(List<EllaTimeRange> ranges) sync*
  {
    if (ranges.isEmpty) {
      return;
    }

    if (ranges.first.begin.seconds > 0) {
      yield new EllaTimeRange(new EllaTime(0), ranges.first.begin);
    }

    for (int i = 1; i < ranges.length; i++)
    {
      EllaTimeRange lastRange = ranges[i - 1];
      EllaTimeRange currentRange = ranges[i];
      yield new EllaTimeRange(lastRange.end, currentRange.begin);
    }

    if (ranges.last.end.seconds < EllaTime.secondsPerDay) {
      yield new EllaTimeRange(ranges.last.end, new EllaTime(EllaTime.secondsPerDay));
    }
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result =  17;
    result = 31 * result + begin.hashCode;
    result = 31 * result + end.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is EllaTimeRange) {
      return other.begin == begin &&
             other.end == end;
    }
    else {
      return false;
    }
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromObject("begin", begin);
    marshalled.setPropertyFromObject("end", end);
  }

  static EllaTimeRange unmarshal(MarshalledObject marshalled)
  {
    return new EllaTimeRange(marshalled.getRequired("begin").asObject(EllaTime.unmarshal)!, marshalled.getRequired("end").asObject(EllaTime.unmarshal)! );
  }
}
