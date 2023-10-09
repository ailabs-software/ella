import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Math.dart";
import "package:ella/math/Axis.dart";
import "package:ella/math/Size.dart";

/**
 * @fileoverview A utility class for representing two-dimensional positions.
 */

/**
 * Class for representing coordinates and positions.
 * @param {number=} opt_x Left, defaults to 0.
 * @param {number=} opt_y Top, defaults to 0.
 * @struct
 * @constructor
 */
class Coordinate implements ISerialisable
{
  /** Constant for coordinate at (0, 0). */
  static final Coordinate naught = new Coordinate(0.0, 0.0);

  late double x;
  late double y;

  Coordinate([double x = 0, double y = 0])
  {
    this.x = x;
    this.y = y;
  }

  /// Returns the distance between `this` and [other].
  double distanceTo(Coordinate other)
  {
    return Math.sqrt( squaredDistance(other) );
  }

  double squaredDistance(Coordinate b)
  {
    return squaredDistanceFrom(this, b);
  }

  /**
   * Returns the squared distance between two coordinates. Squared distances can
   * be used for comparisons when the actual value is not required.
   *
   * Performance note: eliminating the square root is an optimization often used
   * in lower-level languages, but the speed difference is not nearly as
   * pronounced in JavaScript (only a few percent.)
   *
   * @param {!goog.math.Coordinate} a A Coordinate.
   * @param {!goog.math.Coordinate} b A Coordinate.
   * @return {number} The squared distance between {@code a} and {@code b}.
   */
  static double squaredDistanceFrom(Coordinate a, Coordinate b)
  {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return dx * dx + dy * dy;
  }

  Coordinate difference(Coordinate b)
  {
    return differenceFrom(this, b);
  }

  /**
   * Returns the difference between two coordinates as a new
   * goog.math.Coordinate.
   * @param {!goog.math.Coordinate} a A Coordinate.
   * @param {!goog.math.Coordinate} b A Coordinate.
   * @return {!goog.math.Coordinate} A Coordinate representing the difference
   *     between {@code a} and {@code b}.
   */
  static Coordinate differenceFrom(Coordinate a, Coordinate b)
  {
    return new Coordinate(a.x - b.x, a.y - b.y);
  }

  /**
   * Rounds the x and y fields to the next larger integer values.
   * @return {!goog.math.Coordinate} This coordinate with ceil'd fields.
   */
  Coordinate ceil()
  {
    x = x.ceilToDouble();
    y = y.ceilToDouble();
    return this;
  }


  /**
   * Rounds the x and y fields to the next smaller integer values.
   * @return {!goog.math.Coordinate} This coordinate with floored fields.
   */
  Coordinate floor()
  {
    x = x.floorToDouble();
    y = y.floorToDouble();
    return this;
  }


  /**
   * Rounds the x and y fields to the nearest integer values.
   * @return {!goog.math.Coordinate} This coordinate with rounded fields.
   */
  Coordinate round()
  {
    x = x.roundToDouble();
    y = y.roundToDouble();
    return this;
  }

  /**
   * Translates this coordinate by the given offsets. If a {@code goog.math.Coordinate}
   * is given, then the x and y values are translated by the coordinate's x and y.
   * Otherwise, x and y are translated by {@code tx} and {@code opt_ty}
   * respectively.
   * @return {!goog.math.Coordinate} This coordinate after translating.
   */
  Coordinate translate(Coordinate tc)
  {
    this.x += tc.x;
    this.y += tc.y;

    return this;
  }

  /** @param maxCoor -- Beginning of range
      @param minCoor -- End of range */
  Coordinate clamp(Coordinate maxCoor, Coordinate minCoor)
  {
    return max(maxCoor).min(minCoor);
  }

  Coordinate max(Coordinate maxCoor)
  {
    this.x = Math.max(this.x, maxCoor.x);
    this.y = Math.max(this.y, maxCoor.y);
    return this;
  }

  Coordinate min(Coordinate minCoor)
  {
    this.x = Math.min(this.x, minCoor.x);
    this.y = Math.min(this.y, minCoor.y);
    return this;
  }

  /** Multiplies each axis by -1 */
  Coordinate reverseSign()
  {
    this.x = this.x * -1;
    this.y = this.y * -1;
    return this;
  }

  /** Get an axis value. For OO patterns. */
  double getAxis(Axis axis)
  {
    switch (axis)
    {
      case Axis.X:
        return x;
      case Axis.Y:
        return y;
      default:
        throw IllegalArgumentException();
    }
  }

  /** Computes position percent coordinate from graph coordinate, where (0,0) is centre.
   *  (0, 0) becomes (50%, 50%), (-1, -1) becomes (0%, 0%), (1, 1), becomes(100%, 100%). */
  Coordinate graphPointToPositionPercent()
  {
    return new Coordinate( graphPointAxisToPositionPercent(x), graphPointAxisToPositionPercent(y) );
  }

  /** Zero is centre on each axis, so must translate to x/y. */
  static double graphPointAxisToPositionPercent(double coordinateValue)
  {
    // Formula: percent = 50 + (d/1 * 50)
    return 50.0 + (coordinateValue/1 * 50.0);
  }

  /**
   * @return {!goog.math.Size} A new copy of this Coordinate as Size.
   */
  Size toSize()
  {
    return new Size(x, y);
  }

  /**
   * @return {!goog.math.Coordinate} A new copy of this Coordinate.
   */
  Coordinate copy()
  {
    return new Coordinate(this.x, this.y);
  }

  /**
   * Returns a nice string representing the coordinate.
   * @return {string} In the form (50, 73).
   * @override
   */
  @override
  String toString()
  {
    return "(" + this.x.toString() + ", " + this.y.toString() + ")";
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    // Hash code for our fields. Note that field is read.
    result = 31 * result + x.hashCode;
    result = 31 * result + y.hashCode;
    return result;
  }

  /**
   * Compares coordinates for equality.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is Coordinate) {
      return this.x == other.x && this.y == other.y;
    }
    else {
      return false;
    }
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("x", x);
    marshalled.setPropertyFromDouble("y", y);
  }

  /** Encoded object parameter is encoded depending on format. */
  static Coordinate unmarshal(MarshalledObject marshalled)
  {
    double x = marshalled.getRequired("x").asDouble();
    double y = marshalled.getRequired("y").asDouble();
    return new Coordinate(x, y);
  }
}


