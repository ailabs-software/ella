import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/math/Math.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Axis.dart";
import "package:ella/math/BoxDimension.dart";
import "package:ella/math/CardinalDirection.dart";
import "package:ella/math/Rect.dart";
import "package:ella/math/Size.dart";

// Copyright 2006 The Closure Library Authors. All Rights Reserved.
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
 * @fileoverview A utility class for representing a numeric box.
 */

/**
 * Class for representing a box. A box is specified as a top, right, bottom,
 * and left. A box is useful for representing margins and padding.
 *
 * This class assumes 'screen coordinates': larger Y coordinates are further
 * from the top of the screen.
 *
 * @param {number} top Top.
 * @param {number} right Right.
 * @param {number} bottom Bottom.
 * @param {number} left Left.
 * @struct
 * @constructor
 */

class Box implements ISerialisable
{
  static Box ZERO_BOX = new Box(0.0, 0.0, 0.0, 0.0);

  late double top;
  late double right;
  late double bottom;
  late double left;

  Box([double top = 0.0, double right = 0.0, double bottom = 0.0, double left = 0.0])
  {
    /**
     * Top
     * @type {number}
     */
    this.top = top;

    /**
     * Right
     * @type {number}
     */
    this.right = right;

    /**
     * Bottom
     * @type {number}
     */
    this.bottom = bottom;

    /**
     * Left
     * @type {number}
     */
    this.left = left;
  }

  factory Box.fromSymmetric(double side)
  {
    return new Box(side, side, side, side);
  }

  /**
   * @return {double} width The width of this Box.
   */
  double getWidth()
  {
    // Different from Closure Library box as we add the sides together to get width
    return right + left;
  }


  /**
   * @return {double} height The height of this Box.
   */
  double getHeight()
  {
    // Different from Closure Library box as we add the sides together to get height
    return bottom + top;
  }

  /** @param maxBox -- Beginning of range
      @param minBox -- End of range */
  Box clamp(Box maxBox, Box minBox)
  {
    return max(maxBox).min(minBox);
  }

  Box max(Box maxBox)
  {
    top = Math.max(top, maxBox.top);
    right = Math.max(right, maxBox.right);
    bottom = Math.max(bottom, maxBox.bottom);
    left = Math.max(left, maxBox.left);
    return this;
  }

  Box min(Box minBox)
  {
    top = Math.min(top, minBox.top);
    right = Math.min(right, minBox.right);
    bottom = Math.min(bottom, minBox.bottom);
    left = Math.min(left, minBox.left);
    return this;
  }

  /** Get sum of values on axis. */
  double sum(Axis axis)
  {
    switch (axis)
    {
      case Axis.X:
        return left + right;
      case Axis.Y:
        return top + bottom;
      default:
        throw new IllegalArgumentException();
    }
  }

  /** Get sum of all sides */
  double sumOfAllSides()
  {
    return top + right + bottom + left;
  }

  /** Get value accessor for dimension. */
  BoxDimension getBoxDimension(CardinalDirection cardinalDirection)
  {
    return new BoxDimension(this, cardinalDirection);
  }

  /**
   * Scales this size by the given scale factors. The width and height are scaled
   * by {@code sx} and {@code opt_sy} respectively.  If {@code opt_sy} is not
   * given, then {@code sx} is used for both the width and height.
   * @param {number} sx The scale factor to use for the width.
   * @param {number=} opt_sy The scale factor to use for the height.
   * @return {!goog.math.Size} This Size object after scaling.
   */
  void scale(double sx, double sy)
  {
    top *= sy;
    right *= sx;
    bottom *= sy;
    left *= sx;
  }

  Box getPercentOfSize(Size size)
  {
    return new Box(
      top / size.height,
      right / size.width,
      bottom / size.height,
      left / size.width);
  }

  /** Generate a Rect from this box, out of given Size (Size is what Rect is out of). */
  Rect toRect(Size size)
  {
    // x, y, w, h
    return new Rect(left, top, size.width - (left + right), size.height - (top + bottom) );
  }

  /** Clone this object. */
  Box copy()
  {
    return new Box(top, right, bottom, left);
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    // Hash code for our fields. Note that field is read.
    result = 31 * result + top.hashCode;
    result = 31 * result + right.hashCode;
    result = 31 * result + bottom.hashCode;
    result = 31 * result + left.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is Box) {
      return top == other.top &&
             right == other.right &&
             bottom == other.bottom &&
             left == other.left;
    }
    else {
      return false;
    }
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("top", top);
    marshalled.setPropertyFromDouble("right", right);
    marshalled.setPropertyFromDouble("bottom", bottom);
    marshalled.setPropertyFromDouble("left", left);
  }

  /** Encoded object parameter is encoded depending on format. */
  static Box unmarshal(MarshalledObject marshalled)
  {
    double top = marshalled.getRequired("top").asDouble();
    double right = marshalled.getRequired("right").asDouble();
    double bottom = marshalled.getRequired("bottom").asDouble();
    double left = marshalled.getRequired("left").asDouble();
    return new Box(top, right, bottom, left);
  }

  /**
   * Returns a nice string representing the box.
   * @return {string} In the form (50t, 73r, 24b, 13l).
   * @override
   */
  @override
  String toString()
  {
    return "(" + this.top.toString() + "t, " + this.right.toString() + "r, " + this.bottom.toString() + "b, " + this.left.toString() + "l)";
  }
}


