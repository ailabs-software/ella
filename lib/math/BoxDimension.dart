import "package:ella/exception/IllegalStateException.dart";
import "package:ella/math/CardinalDirection.dart";
import "package:ella/math/Box.dart";


class BoxDimension
{
  Box _box;
  /** Cardinal direction. Public but final. */
  final CardinalDirection cardinalDirection;

  BoxDimension(Box this._box, CardinalDirection this.cardinalDirection);

  double getValue()
  {
    if (cardinalDirection == CardinalDirection.North) {
      return _box.top;
    }
    else if (cardinalDirection == CardinalDirection.East) {
      return _box.right;
    }
    else if (cardinalDirection == CardinalDirection.South) {
      return _box.bottom;
    }
    else if (cardinalDirection == CardinalDirection.West) {
      return _box.left;
    }
    else {
      throw new IllegalStateException("BoxDimension.getValue() cannot support ordinal directions as reference to _box field.");
    }
  }

  void setValue(double value)
  {
    if (cardinalDirection == CardinalDirection.North) {
      _box.top = value;
    }
    else if (cardinalDirection == CardinalDirection.East) {
      _box.right = value;
    }
    else if (cardinalDirection == CardinalDirection.South) {
      _box.bottom = value;
    }
    else if (cardinalDirection == CardinalDirection.West) {
      _box.left = value;
    }
    else {
      throw new IllegalStateException("BoxDimension.setValue() cannot support ordinal directions as reference to _box field.");
    }
  }
}


