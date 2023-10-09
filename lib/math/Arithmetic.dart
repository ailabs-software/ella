import "package:ella/math/Math.dart";

/** @fileoverview Util methods for arithmetic */

abstract class Arithmetic
{
  static double toSignificantFigures(double value, int figures)
  {
    double multiplier = Math.pow(10.0, figures.toDouble() ).toDouble();
    return ( value*multiplier ).round() / multiplier;
  }

  static T clamp<T extends num>(T value, T minimumValue, T maximumValue)
  {
    return Math.max(minimumValue, Math.min(maximumValue, value) );
  }

  /** Number is contained by min/max, or equal to. */
  static bool inBounds<T extends num>(T value, T minimumValue, T maximumValue)
  {
    return value == clamp(value, minimumValue, maximumValue);
  }

  static String computePercent(num part, num whole)
  {
    double result;
    if (whole == 0) {
      result = 0.0;
    }
    else {
      result = part / whole * 100.0;
    }

    return toSignificantFigures(result, 2).toString() + "%";
  }
}


