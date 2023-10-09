import "dart:math" as dartMath;

/** @fileoverview Math methods supplement */

class Math
{
  /** The PI constant. */
  static const double PI = dartMath.pi;

  /** A constant holding the maximum value an int can have, 231-1. */
  static const int INT_MAX_VALUE = 2147483647;
  static const int INT_MIN_VALUE = INT_MAX_VALUE * -1;

  static const double DOUBLE_MAX_VALUE = 2147483647.0;
  static const double DOUBLE_MIN_VALUE = DOUBLE_MAX_VALUE * -1;

  /** Return lowest of two values */
  static T min<T extends num>(T a, T b)
  {
    if (a < b) {
      return a;
    }
    else {
      return b;
    }
  }

  /** Return highest of two values */
  static T max<T extends num>(T a, T b)
  {
    if (a > b) {
      return a;
    }
    else {
      return b;
    }
  }

  /** sqrt */
  static double sqrt(num x)
  {
    return dartMath.sqrt(x);
  }

  /** pow */
  static num pow<T extends num>(num x, num exponent)
  {
    return dartMath.pow(x, exponent);
  }

  /** log10 */
  static double log10(num value)
  {
    return dartMath.log(value) / dartMath.log(10);
  }

  /** sin */
  static double sin(num radians)
  {
    return dartMath.sin(radians);
  }

  /** cos */
  static double cos(num radians)
  {
    return dartMath.cos(radians);
  }

  /** atan2 */
  static double atan2(num a, num b)
  {
    return dartMath.atan2(a, b);
  }

  /**
   * The % operator in JavaScript returns the remainder of a / b, but differs from
   * some other languages in that the result will have the same sign as the
   * dividend. For example, -1 % 8 == -1, whereas in some other languages
   * (such as Python) the result would be 7. This function emulates the more
   * correct modulo behavior, which is useful for certain applications such as
   * calculating an offset index in a circular list.
   *
   * @param {number} a The dividend.
   * @param {number} b The divisor.
   * @return {number} a % b where the result is between 0 and b (either 0 <= x < b
   *     or b < x <= 0, depending on the sign of b).
   */
  static double modulo(double a, double b)
  {
    double r = a % b;
    // If r and b differ in sign, add b to wrap the result to the correct sign.
    return (r * b < 0) ? r + b : r;
  }

  /**
   * Converts degrees to radians.
   * @param {number} angleDegrees Angle in degrees.
   * @return {number} Angle in radians.
   */
  static double degreesToRadians(double angleDegrees)
  {
    return angleDegrees * PI / 180.0;
  }

  /**
   * Converts radians to degrees.
   * @param {number} angleRadians Angle in radians.
   * @return {number} Angle in degrees.
   */
  static double radiansToDegrees(double angleRadians)
  {
    return angleRadians * 180 / Math.PI;
  }

  /**
   * For a given angle and radius, finds the X portion of the offset.
   * @param {number} degrees Angle in degrees (zero points in +X direction).
   * @param {number} radius Radius.
   * @return {number} The x-distance for the angle and radius.
   */
  double angleDx(double degrees, double radius)
  {
    return radius * Math.cos(degreesToRadians(degrees));
  }


  /**
   * For a given angle and radius, finds the Y portion of the offset.
   * @param {number} degrees Angle in degrees (zero points in +X direction).
   * @param {number} radius Radius.
   * @return {number} The y-distance for the angle and radius.
   */
  double angleDy(double degrees, double radius)
  {
    return radius * Math.sin(degreesToRadians(degrees));
  }

  // TODO(user): Rename to normalizeAngle, retaining old name as deprecated alias.
  /**
   * Normalizes an angle to be in range [0-360). Angles outside this range will
   * be normalized to be the equivalent angle with that range.
   * @param {number} angle Angle in degrees.
   * @return {number} Standardized angle.
   */
  static double standardAngle(double angle)
  {
    return modulo(angle, 360);
  }

  /**
   * Computes the angle between two points (x1,y1) and (x2,y2).
   * Angle zero points in the +X direction, 90 degrees points in the +Y
   * direction (down) and from there we grow clockwise towards 360 degrees.
   * @param {number} x1 x of first point.
   * @param {number} y1 y of first point.
   * @param {number} x2 x of second point.
   * @param {number} y2 y of second point.
   * @return {number} Standardized angle in degrees of the vector from
   *     x1,y1 to x2,y2.
   */
  static double angle(double x1, double  y1, double x2, double y2)
  {
    return standardAngle(radiansToDegrees(Math.atan2(y2 - y1, x2 - x1)));
  }
}


