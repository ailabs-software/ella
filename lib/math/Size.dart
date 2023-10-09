import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/math/Math.dart";
import "package:ella/math/Axis.dart";
import "package:ella/math/Coordinate.dart";
import "package:ella/math/Rect.dart";

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
 * @fileoverview A utility class for representing two-dimensional sizes.
 * @author brenneman@google.com (Shawn Brenneman)
 */

/**
 * Class for representing sizes consisting of a width and height. Undefined
 * width and height support is deprecated and results in compiler warning.
 * @param {number} width Width.
 * @param {number} height Height.
 * @struct
 * @constructor
 */
class Size implements ISerialisable
{
  /** Empty size */
  static final Size naught = new Size(0.0, 0.0);

  late double width;
  late double height;

  Size([double width = 0.0, double height = 0.0])
  {
    /**
     * Width
     * @type {number}
     */
    this.width = width;

    /**
     * Height
     * @type {number}
     */
    this.height = height;
  }

  factory Size.parseFromAttribute(String data)
  {
    List<String> parts = data.split("x");
    return new Size(double.parse(parts[0]), double.parse(parts[1]) );
  }

  /**
   * Returns a nice string representing size.
   * @return {string} In the form (50 x 73).
   * @override
   */
  @override
  String toString()
  {
    return "(" + width.toString() + " x " + height.toString() + ")";
  }

  @override
  int get hashCode
  {
    // Significant value equality.
    int result = 17;
    result = 31 * result + width.hashCode;
    result = 31 * result + height.hashCode;
    return result;
  }

  /**
   * Compares sizes for equality.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is Size) {
      return width == other.width && height == other.height;
    } 
    else {
      return false;
    }
  }

  /** Get axis. Enables general code to be written without knowing which axis ahead of time. */
  double getAxis(Axis axis)
  {
    switch (axis)
    {
      case Axis.X:
        return width;
      case Axis.Y:
        return height;
      default:
        throw new IllegalArgumentException("Bad axis argument.");
    }
  }

  /**
   * @return {number} The longer of the two dimensions in the size.
   */
  double getLongest()
  {
    return Math.max(width, height);
  }

  /**
   * @return {number} The shorter of the two dimensions in the size.
   */
  double getShortest()
  {
    return Math.min(width, height);
  }


  /**
   * @return {number} The area of the size (width * height).
   */
  double area()
  {
    return width * height;
  }


  /**
   * @return {number} The perimeter of the size (width + height) * 2.
   */
  double perimeter()
  {
    return (width + height) * 2;
  }

  /**
   * @param {!goog.math.Size} target The target size.
   * @return {bool} True if this Size is the same size or smaller than the
   *     target size in both dimensions.
   */
  bool fitsInside(Size target)
  {
    return width <= target.width && height <= target.height;
  }

  /**
   * @return {number} The ratio of the size's width to its height.
   */
  double aspectRatio()
  {
    return width / height;
  }

  /**
   * @return {bool} True if the size has zero area, false if both dimensions
   *     are non-zero numbers.
   */
  bool isEmpty()
  {
    return area() == 0;
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
    width *= sx;
    height *= sy;
  }


  /**
   * Uniformly scales the size to perfectly cover the dimensions of a given size.
   * If the size is already larger than the target, it will be scaled down to the
   * minimum size at which it still covers the entire target. The original aspect
   * ratio will be preserved.
   *
   * This function assumes that both Sizes contain strictly positive dimensions.
   * @param {!goog.math.Size} target The target size.
   */
  void scaleToCover(Size target)
  {
    double s;

    if ( aspectRatio() <= target.aspectRatio() ) {
      s = target.width / width;
    }
    else {
      s = target.height / height;
    }

    scale(s, s);
  }


  /**
   * Uniformly scales the size to fit inside the dimensions of a given size. The
   * original aspect ratio will be preserved.
   *
   * This function assumes that both Sizes contain strictly positive dimensions.
   * @param {!goog.math.Size} target The target size.
   */
  void scaleToFit(Size target)
  {
    double s;

    if ( aspectRatio() > target.aspectRatio() ) {
      s = target.width / width;
    }
    else {
      s = target.height / height;
    }

    scale(s, s);
  }

  /** Scale so that specified dimension matches specified value. */
  void scaleDimension(Axis axis, double s)
  {
    double currentAspectRatio = aspectRatio();
    switch (axis)
    {
      case Axis.X:
        width = s;
        height = (1 / currentAspectRatio) * s;
        break;
      case Axis.Y:
        height = s;
        width = currentAspectRatio * s;
        break;
      default:
        throw new IllegalArgumentException("Bad axis argument.");
    }
  }

  /** Rotate size around 90 degrees (same effect as 270) */
  void rotate90()
  {
    double oldWidth = width;
    width = height;
    height = oldWidth;
  }

  Coordinate toCoordinate()
  {
    return new Coordinate(width, height);
  }

  Rect toRect()
  {
    return new Rect(0.0, 0.0, width, height);
  }

  /**
   * @return {!goog.math.Size} A new copy of this Size.
   */
  Size copy()
  {
    return new Size(width, height);
  }

  /** Size to attribute string */
  String toAttributeString()
  {
    return "${width.round()}x${height.round()}";
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("width", width);
    marshalled.setPropertyFromDouble("height", height);
  }

  /** Encoded object parameter is encoded depending on format. */
  static Size unmarshal(MarshalledObject marshalled)
  {
    double width = marshalled.getRequired("width").asDouble();
    double height = marshalled.getRequired("height").asDouble();
    return new Size(width, height);
  }
}
