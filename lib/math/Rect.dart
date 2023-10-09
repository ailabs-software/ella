import "package:ella/math/Math.dart";
import "package:ella/math/Box.dart";
import "package:ella/math/CardinalDirectionType.dart";
import "package:ella/math/Coordinate.dart";
import "package:ella/math/RectEdge.dart";
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
 * @fileoverview A utility class for representing rectangles.
 */

/**
 * Class for representing rectangular regions.
 * @param {number} x Left.
 * @param {number} y Top.
 * @param {number} w Width.
 * @param {number} h Height.
 * @struct
 * @constructor
 */
class Rect
{
  late double left;
  late double top;
  late double width;
  late double height;

  Rect([double x = 0.0, double y = 0.0, double w = 0.0, double h = 0.0])
  {
    /** @type {number} */
    this.left = x;

    /** @type {number} */
    this.top = y;

    /** @type {number} */
    this.width = w;

    /** @type {number} */
    this.height = h;
  }

  /**
    * Returns a nice string representing size and dimensions of rectangle.
    * @return {string} In the form (50, 73 - 75w x 25h).
    * @override
    */
  @override
  String toString()
  {
    return "(" + left.toString() + ", " + top.toString() + " - " + width.toString() + "w x " + height.toString() + "h)";
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    // Hash code for our fields. Note that field is read.
    result = 31 * result + width.hashCode;
    result = 31 * result + height.hashCode;
    result = 31 * result + top.hashCode;
    result = 31 * result + left.hashCode;
    return result;
  }

  /**
   * Compares rectangles for equality.
   * @param {goog.math.Rect} a A Rectangle.
   * @param {goog.math.Rect} b A Rectangle.
   * @return {bool} True iff the rectangles have the same left, top, width,
   *     and height, or if both are null.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is Rect) {
      return this.left == other.left && this.width == other.width && this.top == other.top && this.height == other.height;
    }
    else {
      return false;
    }
  }


  /**
   * Computes the intersection of this rectangle and the rectangle parameter.  If
   * there is no intersection, returns false and leaves this rectangle as is.
   * @param {goog.math.Rect} rect A Rectangle.
   * @return {bool} True iff this rectangle intersects with the parameter.
   */
  bool intersection(Rect rect)
  {
    double x0 = Math.max(this.left, rect.left);
    double x1 = Math.min(this.left + this.width, rect.left + rect.width);

    if (x0 <= x1) {
      double y0 = Math.max(this.top, rect.top);
      double y1 = Math.min(this.top + this.height, rect.top + rect.height);

      if (y0 <= y1) {
        this.left = x0;
        this.top = y0;
        this.width = x1 - x0;
        this.height = y1 - y0;

        return true;
      }
    }
    return false;
  }

  /**
   * Returns whether two rectangles intersect. Two rectangles intersect if they
   * touch at all, for example, two zero width and height rectangles would
   * intersect if they had the same top and left.
   * @param {goog.math.Rect} a A Rectangle.
   * @param {goog.math.Rect} b A Rectangle.
   * @return {bool} Whether a and b intersect.
   */
  static bool intersectsFrom(Rect a, Rect b)
  {
    return (
        a.left <= b.left + b.width && b.left <= a.left + a.width &&
        a.top <= b.top + b.height && b.top <= a.top + a.height);
  }


  /**
   * Returns whether a rectangle intersects this rectangle.
   * @param {goog.math.Rect} rect A rectangle.
   * @return {bool} Whether rect intersects this rectangle.
   */
  bool intersects(Rect rect)
  {
    return intersectsFrom(this, rect);
  }


  /**
   * Expand this rectangle to also include the area of the given rectangle.
   * @param {goog.math.Rect} rect The other rectangle.
   */
  void boundingRect(Rect rect)
  {
    // We compute right and bottom before we change left and top below.
    double right = Math.max(this.left + this.width, rect.left + rect.width);
    double bottom = Math.max(this.top + this.height, rect.top + rect.height);

    this.left = Math.min(this.left, rect.left);
    this.top = Math.min(this.top, rect.top);

    this.width = right - this.left;
    this.height = bottom - this.top;
  }

  /** Fit this rectangle into the other rectangle by resizing it */
  void fitInto(Rect rect)
  {
    // left constriant
    if (left < rect.left) {
      width -= rect.left - left;
      left = rect.left;
    }
    // top constriant
    if (top < rect.top) {
      height -= rect.top - top;
      top = rect.top;
    }
    // width constraint
    width = Math.min(width + left, rect.width + rect.left) - left;
    // height constraint
    height = Math.min(height + top, rect.height + rect.top) - top;
  }

  /**
   * Tests whether this rectangle entirely contains another rectangle.
   *
   * @param {goog.math.Rect|goog.math.Coordinate} another The rectangle to test for containment.
   * @return {bool} Whether this rectangle contains given rectangle or coordinate.
   */
  bool contains(Rect another)
  {
    return this.left <= another.left &&
           this.left + this.width >= another.left + another.width &&
           this.top <= another.top &&
           this.top + this.height >= another.top + another.height;
  }

  /**
   * Tests whether this rectangle entirely contains coordinate.
   *
   * @param {goog.math.Coordinate} point The coordinate to test for containment.
   * @return {boolean} Whether this rectangle contains given coordinate.
   */
  bool containsPoint(Coordinate point)
  {
    return point.x >= this.left && point.x <= this.left + this.width &&
          point.y >= this.top && point.y <= this.top + this.height;
  }


  /**
   * @param {!goog.math.Coordinate} point A coordinate.
   * @return {number} The squared distance between the point and the closest
   *     point inside the rectangle. Returns 0 if the point is inside the
   *     rectangle.
   */
  double squaredDistance(Coordinate point)
  {
    double dx = point.x < this.left ?
             this.left - point.x :
             Math.max(point.x - (this.left + this.width), 0.0);

    double dy = point.y < this.top ? this.top - point.y :
                                  Math.max(point.y - (this.top + this.height), 0.0);
    return dx * dx + dy * dy;
  }


  /**
   * @param {!goog.math.Coordinate} point A coordinate.
   * @return {number} The distance between the point and the closest point
   *     inside the rectangle. Returns 0 if the point is inside the rectangle.
   */
  double distance(Coordinate point)
  {
    return Math.sqrt( squaredDistance(point) );
  }

  /** Returns right computeed value. */
  double getRight()
  {
    return left + width;
  }

  /** Gets left centre */
  Coordinate getLeftCentre()
  {
    return new Coordinate(left, top + height / 2);
  }

  /** Gets right centre */
  Coordinate getRightCentre()
  {
    return new Coordinate(left + width, top + height / 2);
  }

  /** Returns bottom computeed value. */
  double getBottom()
  {
    return top + height;
  }

  /**
   * @return {!goog.math.Coordinate} A new coordinate for the top-left corner of
   *     the rectangle.
   */
  Coordinate getTopLeft()
  {
    return new Coordinate(left, top);
  }

  /** Gets top centre */
  Coordinate getTopCentre()
  {
    return new Coordinate(left + width / 2, top);
  }

  /**
   * @return {!goog.math.Coordinate} A new coordinate for the top-right corner of
   *     the rectangle.
   */
  Coordinate getTopRight()
  {
    return new Coordinate(left + width, top);
  }

  /**
   * @return {!goog.math.Coordinate} A new coordinate for the center of the
   *     rectangle.
   */
  Coordinate getCentre()
  {
    return new Coordinate(left + width / 2, top + height / 2);
  }

  /**
   * @return {!goog.math.Coordinate} A new coordinate for the bottom-left corner
   *     of the rectangle.
   */
  Coordinate getBottomLeft()
  {
    return new Coordinate(left, top + height);
  }

  /** Gets bottom centre */
  Coordinate getBottomCentre()
  {
    return new Coordinate(left + width / 2, top + height);
  }

  /**
   * @return {!goog.math.Coordinate} A new coordinate for the bottom-right corner
   *     of the rectangle.
   */
  Coordinate getBottomRight()
  {
    return new Coordinate(left + width, top + height);
  }
  
  /** Set Rect width and height from Size object. */
  void setSize(Size size)
  {
    width = size.width;
    height = size.height;
  }

  /** Sets top left. */
  void setTopLeft(Coordinate point)
  {
    left = point.x;
    top = point.y;
  }

  /** Sets top right. */
  void setTopRight(Coordinate point)
  {
    left = point.x - width;
    top = point.y;
  }

  /** Sets right */
  void setRight(double value)
  {
    left = value - width;
  }

  /** Sets bottom */
  void setBottom(double value)
  {
    top = value - height;
  }

  /** Sets bottom left. */
  void setBottomLeft(Coordinate point)
  {
    left = point.x;
    top = point.y - height;
  }

  /** Sets bottom right. */
  void setBottomRight(Coordinate point)
  {
    left = point.x - width;
    top = point.y - height;
  }

  /** Sets center of this Rect to be at this center point. */
  void setCenter(Coordinate point)
  {
    left = point.x - width * 0.5;
    top = point.y - height * 0.5;
  }

  /** The order of the input parameters does not matter, coordinates are sorted based on comparison.
   *  It is important that each of the four coordinates are ordered based on value, as a Rect never has negative width or height. */
  void setTopLeftAndBottomRight(Coordinate point1, Coordinate point2)
  {
    left = Math.min(point1.x, point2.x);
    top = Math.min(point1.y, point2.y);
    width = Math.max(point1.x, point2.x) - left;
    height = Math.max(point1.y, point2.y) - top;
  }


  /**
   * Translates this rectangle by the given offsets. If a
   * {@code goog.math.Coordinate} is given, then the left and top values are
   * translated by the coordinate's x and y values. Otherwise, top and left are
   * translated by {@code tx} and {@code opt_ty} respectively.
   * @param {number|goog.math.Coordinate} tx The value to translate left by or the
   *     the coordinate to translate this rect by.
   * @param {number=} opt_ty The value to translate top by.
   * @return {!goog.math.Rect} This rectangle after translating.
   */
  Rect translate(Coordinate tx)
  {
    left += tx.x;
    top += tx.y;
    return this;
  }

  /**  Translate rect so it is relative to a coordinate */
  Rect translateRelativeToCoordinate(Coordinate point)
  {
    return translate( point.reverseSign() );
  }

  /**  Translate rect so it is relative to the top-left position (goes inside of) another rect. */
  Rect translateRelativeToRect(Rect otherRect)
  {
    return translateRelativeToCoordinate( otherRect.getTopLeft() );
  }

  /**
   * Scales this rectangle by the given scale factors. The left and width values
   * are scaled by {@code sx} and the top and height values are scaled by
   * {@code opt_sy}.  If {@code opt_sy} is not given, then all fields are scaled
   * by {@code sx}.
   * @param {number} sx The scale factor to use for the x dimension.
   * @param {number=} opt_sy The scale factor to use for the y dimension.
   * @return {!goog.math.Rect} This rectangle after scaling.
   */
  void scale(double sx, double sy)
  {
    left *= sx;
    width *= sx;
    top *= sy;
    height *= sy;
  }

  /** Box is interpreted as a proportion, with 100 being the highest unit value.
   *   Tip: Set the aspect ratio of this Rect before calling this method,
   *    which is done by setting the height to 1.0 and the width to the aspect ratio.
   */
  void boundingBoxPreservingAspectRatioXmidYmid(Box box, Rect rect)
  {
    double aspectRatioBefore = toSize().aspectRatio();

    // Compute size based on box which will contain rect within space defined by box.
    width = (rect.width * 100.0) / (100.0 - (box.left + box.right) );
    height = (rect.height * 100.0) / (100.0 - (box.top + box.bottom) );

    // Initial position.
    left = rect.left;
    top = rect.top;

    // Compute position from box such that box contains rect.
    left -= (box.left/100.0) * width;
    top -= (box.top/100.0) * height;

    // Correction for aspect ratio. This is necessary because we may be given Box.ZERO_BOX, which won't match aspect ratio.
    // We must gracefully handle this so we can get a good initial state.
    double aspectRatio = toSize().aspectRatio();

    if (aspectRatio > aspectRatioBefore) {
      double oldHeight = height;
      height = width * (1/aspectRatioBefore);
      // Adjust position so as to center (XmidYMid).
      top -= 0.5 * ( (height - oldHeight) / height ) * height;
    }
    else if (aspectRatio < aspectRatioBefore) {
      double oldWidth = width;
      width = height * aspectRatioBefore;
      // Adjust position so as to center (XmidYMid).
      left -= 0.5 * ( (width - oldWidth) / width ) * width;
    }
  }

  /** Get point from edge of rect */
  RectEdge getEdge(CardinalDirectionType edge)
  {
    Coordinate point;
    switch (edge)
    {
      case CardinalDirectionType.NorthWest: // Top left
        point = getTopLeft();
        return new RectEdge(CardinalDirectionType.NorthWest, point);
      case CardinalDirectionType.North: // 12-o-clock (top centre)
        point = getTopLeft();
        point.x = left + width / 2;
        return new RectEdge(CardinalDirectionType.North, point);
      case CardinalDirectionType.NorthEast: // Top right
        point = getTopLeft();
        point.x += width;
        return new RectEdge(CardinalDirectionType.NorthEast, point);
      case CardinalDirectionType.East: // 3-o-clock (right centre)
        point = getTopLeft();
        point.x += width;
        point.y = top + height / 2;
        return new RectEdge(CardinalDirectionType.East, point);
      case CardinalDirectionType.SouthEast: // Bottom right
        point = getBottomRight();
        return new RectEdge(CardinalDirectionType.SouthEast, point);
      case CardinalDirectionType.South: // Six-o-clock (bottom centre)
        point = getBottomRight();
        point.x = left + width / 2;
        return new RectEdge(CardinalDirectionType.South, point);
      case CardinalDirectionType.SouthWest: // Bottom left
        point = getTopLeft();
        point.y += height;
        return new RectEdge(CardinalDirectionType.SouthWest, point);
      case CardinalDirectionType.West: // 9-o-clock (left centre)
        point = getTopLeft();
        point.y = top + height / 2;
        return new RectEdge(CardinalDirectionType.West, point);
    }
  }

  Size toSize()
  {
    return new Size(width, height);
  }

  /**
   * @return {!goog.math.Rect} A new copy of this Rectangle.
   */
  Rect copy()
  {
    return new Rect(left, top, width, height);
  }
}



