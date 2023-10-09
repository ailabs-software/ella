import "package:ella/math/Coordinate.dart";

/** @fileoverview Util methods for algebra */

class Algebra
{
  /** From Closure:
  * Performs linear interpolation between values a and b. Returns the value
  * between a and b proportional to x (when x is between 0 and 1. When x is
  * outside this range, the return value is a linear extrapolation).
  * @param {double} a A number.
  * @param {double} b A number.
  * @param {double} x The proportion between a and b.
  * @return {double} The interpolated value between a and b.
  */
  static double lerp(double a, double b, double x)
  {
    return a + x * (b - a);
  }

  /**
    Finds points which X are is between on X axis, closest . 
    IMPORTANT: Does not sort: Assumes order of coordinates is in increaing values of X.
      Will include is equal, so inclusive.
    @returnValue Array with pair. */
  static List<Coordinate> getNearestSurroundingPair(List<Coordinate> line, double x)
  {
    if (line.length < 2) {
      throw new Exception("Algebra.getNearestSurroundingPair: At least two coordinates must be defined in the line.");
    }

    // Find closest points where x is between.
    int i=0;
    Coordinate? nextPoint = null;
    for (; i < line.length - 1; i++)
    {
      nextPoint = line[i+1];

      if (nextPoint.x > x) {
        break;
      }
    }    

    // Return the path.
    List<Coordinate> surroundingPair = [line[i], nextPoint!];
    return surroundingPair;
  }
}




