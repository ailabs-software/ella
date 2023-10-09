import "package:ella/math/Math.dart";

// Copyright 2008 The Closure Library Authors. All Rights Reserved.
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
 * @fileoverview A utility class for representing three-dimensional points.
 *
 * Based heavily on coordinate.js by:
 */


/**
 * Class for representing coordinates and positions in 3 dimensions.
 *
 * @param {number=} opt_x X coordinate, defaults to 0.
 * @param {number=} opt_y Y coordinate, defaults to 0.
 * @param {number=} opt_z Z coordinate, defaults to 0.
 * @struct
 * @constructor
 */
// @class {goog.math.Coordinate3}
class Coordinate3
{
  /**
  * X-value
  * @type {number}
  */
  late double x;
  /**
   * Y-value
   * @type {number}
   */
  late double y;
  /**
  * Z-value
  * @type {number}
  */
  late double z;

  Coordinate3(double x, double y, double z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  /**
   * Returns a nice string representing the coordinate.
   *
   * @return {string} In the form (50, 73, 31).
   * @override
   */
  @override
  String toString()
  {
    return "(" + this.x.toString() + ", " + this.y.toString() + ", " + this.z.toString() + ")";
  }

  @override
  int get hashCode
  {
    // Significant value equality.
    int result = 17;
    result = 31 * result + x.hashCode;
    result = 31 * result + y.hashCode;
    result = 31 * result + z.hashCode;
    return result;
  }

  /**
   * Compares coordinates for equality.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is Coordinate3) {
      return this.x == other.x && this.y == other.y && this.z == other.z;
    }
    else {
      return false;
    }
  }


  /**
   * Returns the distance between two coordinates.
   *
   * @param {goog.math.Coordinate3} b A Coordinate3.
   * @return {number} The distance between {@code a} and {@code b}.
   */
  double distance(Coordinate3 b)
  {
    double dx = this.x - b.x;
    double dy = this.y - b.y;
    double dz = this.z - b.z;
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  }


  /**
   * Returns the squared distance between two coordinates. Squared distances can
   * be used for comparisons when the actual value is not required.
   *
   * Performance note: eliminating the square root is an optimization often used
   * in lower-level languages, but the speed difference is not nearly as
   * pronounced in JavaScript (only a few percent.)
   *
   * @param {goog.math.Coordinate3} b A Coordinate3.
   * @return {number} The squared distance between {@code a} and {@code b}.
   */
  double squaredDistance(Coordinate3 b)
  {
    double dx = this.x - b.x;
    double dy = this.y - b.y;
    double dz = this.z - b.z;
    return dx * dx + dy * dy + dz * dz;
  }


  /**
   * Returns the difference between two coordinates as a new
   * goog.math.Coordinate3.
   *
   * @param {goog.math.Coordinate3} b A Coordinate3.
   * @return {!goog.math.Coordinate3} A Coordinate3 representing the difference
   *     between {@code a} and {@code b}.
   */
  Coordinate3 difference(Coordinate3 b)
  {
    return new Coordinate3(this.x - b.x, this.y - b.y, this.z - b.z);
  }

  /**
   * @return {!goog.math.Coordinate3} A new copy of this Coordinate3.
   */
  Coordinate3 copy()
  {
    return new Coordinate3(this.x, this.y, this.z);
  }
}


