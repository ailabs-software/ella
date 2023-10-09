import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Represents an integer range */

class IntegerRange implements ISerialisable
{
  final int begin;

  final int end;

  IntegerRange(int this.begin, int this.end);

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    result = 31 * result + begin;
    result = 31 * result + end;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if ( other is IntegerRange) {
      return other.begin == begin &&
             other.end == end;
    }
    else {
      return false;
    }
  }

  int get spans
  {
    return end - begin;
  }

  bool contains(int value)
  {
    return value >= begin && value <= end;
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromInt("begin", begin);
    marshalled.setPropertyFromInt("end", end);
  }

  static IntegerRange unmarshal(MarshalledObject marshalled)
  {
    return new IntegerRange(
      marshalled.getRequired("begin").asInt(),
      marshalled.getRequired("end").asInt()
    );
  }
}
