import "package:ella/math/Math.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Coordinate.dart";
import "package:ella/math/Algebra.dart";

// Copyright 2007 The Closure Library Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS-IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/**
 * @fileoverview Represents a cubic Bezier curve.
 *
 * Uses the deCasteljau algorithm to compute points on the curve.
 * http://en.wikipedia.org/wiki/De_Casteljau's_algorithm
 *
 * Currently it uses an unrolled version of the algorithm for speed.  Eventually
 * it may be useful to use the loop form of the algorithm in order to support
 * curves of arbitrary degree.
 *
 * @author robbyw@google.com (Robby Walker)
 */

class Bezier implements ISerialisable
{
  /**
   * Constant used to approximate ellipses.
   * See: http://canvaspaint.org/blog/2006/12/ellipse/
   * @type {number}
   */
  static final double KAPPA = 4 * (Math.sqrt(2) - 1) / 3;

  /** Linear curve */
  static final Bezier LINEAR = new Bezier(0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

  late double x0;
  late double y0;

  late double x1;
  late double y1;

  late double x2;
  late double y2;

  late double x3;
  late double y3;

  /**
   * Object representing a cubic bezier curve.
   * @param {number} x0 X coordinate of the start point.
   * @param {number} y0 Y coordinate of the start point.
   * @param {number} x1 X coordinate of the first control point.
   * @param {number} y1 Y coordinate of the first control point.
   * @param {number} x2 X coordinate of the second control point.
   * @param {number} y2 Y coordinate of the second control point.
   * @param {number} x3 X coordinate of the end point.
   * @param {number} y3 Y coordinate of the end point.
   * @struct
   * @constructor
   * @final
   */
  Bezier(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3)
  {
    /**
     * X coordinate of the first point.
     * @type {number}
     */
    this.x0 = x0;

    /**
     * Y coordinate of the first point.
     * @type {number}
     */
    this.y0 = y0;

    /**
     * X coordinate of the first control point.
     * @type {number}
     */
    this.x1 = x1;

    /**
     * Y coordinate of the first control point.
     * @type {number}
     */
    this.y1 = y1;

    /**
     * X coordinate of the second control point.
     * @type {number}
     */
    this.x2 = x2;

    /**
     * Y coordinate of the second control point.
     * @type {number}
     */
    this.y2 = y2;

    /**
     * X coordinate of the end point.
     * @type {number}
     */
    this.x3 = x3;

    /**
     * Y coordinate of the end point.
     * @type {number}
     */
    this.y3 = y3;
  }

  factory Bezier.fromCoordinates(Coordinate startPoint, Coordinate control1, Coordinate control2, Coordinate endPoint)
  {
    return new Bezier(startPoint.x, startPoint.y, control1.x, control1.y, control2.x, control2.y, endPoint.x, endPoint.y);
  }

  /**
   * @return {!goog.math.Bezier} A copy of this curve.
   */
  Bezier copy()
  {
    return new Bezier(
        this.x0, this.y0, this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    // Hash code for our fields. Note that field is read.
    result = 31 * result + x0.hashCode;
    result = 31 * result + y0.hashCode;
    result = 31 * result + x1.hashCode;
    result = 31 * result + y1.hashCode;
    result = 31 * result + x2.hashCode;
    result = 31 * result + y2.hashCode;
    result = 31 * result + x3.hashCode;
    result = 31 * result + y3.hashCode;
    return result;
  }

  /**
   * Test if the given curve is exactly the same as this one.
   * @param {goog.math.Bezier} other The other curve.
   * @return {boolean} Whether the given curve is the same as this one.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is Bezier) {
      return this.x0 == other.x0 && this.y0 == other.y0 && this.x1 == other.x1 &&
        this.y1 == other.y1 && this.x2 == other.x2 && this.y2 == other.y2 &&
        this.x3 == other.x3 && this.y3 == other.y3;
    }
    else {
      return false;
    }
  }

  // Convenience getters.

  Coordinate get startPoint
  {
    return new Coordinate(x0, y0);
  }

  Coordinate get controlPoint1
  {
    return new Coordinate(x1, y1);
  }

  Coordinate get controlPoint2
  {
    return new Coordinate(x2, y2);
  }

  Coordinate get endPoint
  {
    return new Coordinate(x3, y3);
  }

  /**
   * Modifies the curve in place to progress in the opposite direction.
   */
  void flip()
  {
    double temp = this.x0;
    this.x0 = this.x3;
    this.x3 = temp;
    temp = this.y0;
    this.y0 = this.y3;
    this.y3 = temp;

    temp = this.x1;
    this.x1 = this.x2;
    this.x2 = temp;
    temp = this.y1;
    this.y1 = this.y2;
    this.y2 = temp;
  }

  /**
   * Computes the curve's X coordinate at a point between 0 and 1.
   * @param {number} t The point on the curve to find.
   * @return {number} The computed coordinate.
   */
  double getPointX(double t)
  {
    // Special case start and end.
    if (t == 0) {
      return this.x0;
    } else if (t == 1) {
      return this.x3;
    }

    // Step one - from 4 points to 3
    double ix0 = Algebra.lerp(this.x0, this.x1, t);
    double ix1 = Algebra.lerp(this.x1, this.x2, t);
    double ix2 = Algebra.lerp(this.x2, this.x3, t);

    // Step two - from 3 points to 2
    ix0 = Algebra.lerp(ix0, ix1, t);
    ix1 = Algebra.lerp(ix1, ix2, t);

    // Final step - last point
    return Algebra.lerp(ix0, ix1, t);
  }

  /**
   * Computes the curve's Y coordinate at a point between 0 and 1.
   * @param {number} t The point on the curve to find.
   * @return {number} The computed coordinate.
   */
  double getPointY(double t)
  {
    // Special case start and end.
    if (t == 0) {
      return this.y0;
    }
    else if (t == 1) {
      return this.y3;
    }

    // Step one - from 4 points to 3
    double iy0 = Algebra.lerp(this.y0, this.y1, t);
    double iy1 = Algebra.lerp(this.y1, this.y2, t);
    double iy2 = Algebra.lerp(this.y2, this.y3, t);

    // Step two - from 3 points to 2
    iy0 = Algebra.lerp(iy0, iy1, t);
    iy1 = Algebra.lerp(iy1, iy2, t);

    // Final step - last point
    return Algebra.lerp(iy0, iy1, t);
  }

  /**
   * Computes the curve at a point between 0 and 1.
   * @param {number} t The point on the curve to find.
   * @return {!goog.math.Coordinate} The computed coordinate.
   */
  Coordinate getPoint(double t)
  {
    return new Coordinate( getPointX(t), getPointY(t) );
  }

  /**
   * Changes this curve in place to be the portion of itself from [t, 1].
   * @param {number} t The start of the desired portion of the curve.
   */
  void subdivideLeft(double t)
  {
    if (t == 1) {
      return;
    }

    // Step one - from 4 points to 3
    double ix0 = Algebra.lerp(this.x0, this.x1, t);
    double iy0 = Algebra.lerp(this.y0, this.y1, t);

    double ix1 = Algebra.lerp(this.x1, this.x2, t);
    double iy1 = Algebra.lerp(this.y1, this.y2, t);

    double ix2 = Algebra.lerp(this.x2, this.x3, t);
    double iy2 = Algebra.lerp(this.y2, this.y3, t);

    // Collect our new x1 and y1
    this.x1 = ix0;
    this.y1 = iy0;

    // Step two - from 3 points to 2
    ix0 = Algebra.lerp(ix0, ix1, t);
    iy0 = Algebra.lerp(iy0, iy1, t);

    ix1 = Algebra.lerp(ix1, ix2, t);
    iy1 = Algebra.lerp(iy1, iy2, t);

    // Collect our new x2 and y2
    this.x2 = ix0;
    this.y2 = iy0;

    // Final step - last point
    this.x3 = Algebra.lerp(ix0, ix1, t);
    this.y3 = Algebra.lerp(iy0, iy1, t);
  }

  /**
   * Changes this curve in place to be the portion of itself from [0, t].
   * @param {number} t The end of the desired portion of the curve.
   */
  void subdivideRight(double t)
  {
    flip();
    subdivideLeft(1 - t);
    flip();
  }

  /**
   * Changes this curve in place to be the portion of itself from [s, t].
   * @param {number} s The start of the desired portion of the curve.
   * @param {number} t The end of the desired portion of the curve.
   */
  void subdivide(double s, double t)
  {
    subdivideRight(s);
    subdivideLeft((t - s) / (1 - s));
  }

  /**
   * Computes the position t of a point on the curve given its x coordinate.
   * That is, for an input xVal, finds t s.t. getPointX(t) = xVal.
   * As such, the following should always be true up to some small epsilon:
   * t ~ solvePositionFromXValue(getPointX(t)) for t in [0, 1].
   * @param {number} xVal The x coordinate of the point to find on the curve.
   * @return {number} The position t.
   */
  double solvePositionFromXValue(double xVal)
  {
    // Desired precision on the computation.
    double epsilon = 1e-6;

    // Initial estimate of t using linear interpolation.
    double t = (xVal - this.x0) / (this.x3 - this.x0);
    if (t <= 0) {
      return 0;
    }
    else if (t >= 1) {
      return 1;
    }

    // Try gradient descent to solve for t. If it works, it is very fast.
    double tMin = 0;
    double tMax = 1;
    double value = 0;
    for (double i = 0; i < 8; i++)
    {
      value = getPointX(t);
      double derivative = (getPointX(t + epsilon) - value) / epsilon;
      if ( (value - xVal).abs() < epsilon) {
        return t;
      }
      else if ( derivative.abs() < epsilon) {
        break;
      }
      else {
        if (value < xVal) {
          tMin = t;
        }
        else {
          tMax = t;
        }
        t -= (value - xVal) / derivative;
      }
    }

    // If the gradient descent got stuck in a local minimum, e.g. because
    // the derivative was close to 0, use a Dichotomy refinement instead.
    // We limit the number of interations to 8.
    for (double i = 0; (value - xVal).abs() > epsilon && i < 8; i++)
    {
      if (value < xVal) {
        tMin = t;
        t = (t + tMax) / 2;
      } else {
        tMax = t;
        t = (t + tMin) / 2;
      }
      value = getPointX(t);
    }
    return t;
  }

  /**
   * Computes the y coordinate of a point on the curve given its x coordinate.
   * @param {number} xVal The x coordinate of the point on the curve.
   * @return {number} The y coordinate of the point on the curve.
   */
  double solveYValueFromXValue(double xVal)
  {
    return getPointY( solvePositionFromXValue(xVal) );
  }

  double length()
  {
    int steps = 10;
    double length = 0.0;
    late double px;
    late double py;

    for (double i = 0.0; i <= steps; i += 1)
    {
      double t = i / steps;
      double cx = _point(
        t,
        x0,
        x1,
        x2,
        x3,
      );
      double cy = _point(
        t,
        y0,
        y1,
        y2,
        y3,
      );
      if (i > 0) {
        double xdiff = cx - px;
        double ydiff = cy - py;
        length += Math.sqrt((xdiff * xdiff) + (ydiff * ydiff));
      }
      px = cx;
      py = cy;
    }

    return length;
  }

  static double _point(double t, double start, double c1, double c2, double end)
  {
    return (start * (1.0 - t) * (1.0 - t) * (1.0 - t)) +
        (3.0 * c1 * (1.0 - t) * (1.0 - t) * t) +
        (3.0 * c2 * (1.0 - t) * t * t) +
        (end * t * t * t);
  }

  /** Returns CSS string representation of bezier.
   *  Assumes anchor points are (0, 0) and (1, 1)! */
  String toCssAnimationTimingFunction()
  {
    return "cubic-bezier(${x1}, ${y1}, ${x2}, ${y2})";
  }

  /** return string representation */
  @override
  String toString()
  {
    return "Bezier{${x0}, ${y0}, ${x1}, ${y1}, ${x2}, ${y2}, ${x3}, ${y3}}";
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("x0", x0);
    marshalled.setPropertyFromDouble("y0", y0);
    marshalled.setPropertyFromDouble("x1", x1);
    marshalled.setPropertyFromDouble("y1", y1);
    marshalled.setPropertyFromDouble("x2", x2);
    marshalled.setPropertyFromDouble("y2", y2);
    marshalled.setPropertyFromDouble("x3", x3);
    marshalled.setPropertyFromDouble("y3", y3);
  }

  static Bezier unmarshal(MarshalledObject marshalled)
  {
    return new Bezier(
      marshalled.getRequired("x0").asDouble(),
      marshalled.getRequired("y0").asDouble(),
      marshalled.getRequired("x1").asDouble(),
      marshalled.getRequired("y1").asDouble(),
      marshalled.getRequired("x2").asDouble(),
      marshalled.getRequired("y2").asDouble(),
      marshalled.getRequired("x3").asDouble(),
      marshalled.getRequired("y3").asDouble() );
  }
}
