import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Represents a range */

class Range implements ISerialisable
{
  // Common ranges
  static final Range PERCENT_RANGE = new Range(0.0, 100.0);

  late num minValue;

  late num maxValue;

  Range(num minValue, num maxValue)
  {
    this.minValue = minValue;
    this.maxValue = maxValue;
  }

  /** Contains, containing bounds. Inclusive. */
  bool contains(num value)
  {
    return value.toDouble() >= minValue.toDouble() && value.toDouble() <= maxValue.toDouble();
  }

  /** Range overlaps other range */
  bool overlaps(Range other)
  {
    return contains(other.minValue) || contains(other.maxValue);
  }

  @override
  bool operator ==(Object other)
  {
    if (other is Range) {
      return other.minValue == minValue &&
             other.maxValue == maxValue;
    }
    else {
      return false;
    }
  }

  /** Implementation from Effective Java 2nd Edition Page 48 */
  @override
  int get hashCode
  {
    int result = 17;
    result = 31 * result + minValue.toInt();
    result = 31 * result + maxValue.toInt();
    return result;
  }

  @override
  String toString()
  {
    return "ella.math.Range{" + minValue.toString() + ", " + maxValue.toString() + "}";
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("minValue", minValue.toDouble());
    marshalled.setPropertyFromDouble("maxValue", maxValue.toDouble());
  }

  static Range unmarshal(MarshalledObject marshalled)
  {
    return new Range(marshalled.getRequired("minValue").asDouble(), marshalled.getRequired("maxValue").asDouble() );
  }
}



