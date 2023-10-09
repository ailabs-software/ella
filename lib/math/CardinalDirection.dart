import "package:ella/math/Axis.dart";
import "package:ella/math/Coordinate.dart";
import "package:ella/math/CardinalDirectionType.dart";

/** @fileoverview Address the 8 places resizers need to appear. Is a Java enum. */

class CardinalDirection
{
  static final CardinalDirection North = new CardinalDirection(CardinalDirectionType.North, new Coordinate(50.0, 0.0), Axis.Y, false, true, false, true, 1.0, "cardinal_direction_north");
  static final CardinalDirection NorthEast = new CardinalDirection(CardinalDirectionType.NorthEast, new Coordinate(100.0, 0.0), null, true, true, false, true, null, "cardinal_direction_northeast");
  static final CardinalDirection East = new CardinalDirection(CardinalDirectionType.East, new Coordinate(100.0, 50.0), Axis.X, true, false, false, false, -1.0, "cardinal_direction_east");
  static final CardinalDirection SouthEast = new CardinalDirection(CardinalDirectionType.SouthEast, new Coordinate(100.0, 100.0), null, true, true, false, false, null, "cardinal_direction_southeast");
  static final CardinalDirection South = new CardinalDirection(CardinalDirectionType.South, new Coordinate(50.0, 100.0), Axis.Y, false, true, false, false, -1.0, "cardinal_direction_south");
  static final CardinalDirection SouthWest = new CardinalDirection(CardinalDirectionType.SouthWest, new Coordinate(0.0, 100.0), null, true, true, true, false, null, "cardinal_direction_southwest");
  static final CardinalDirection West = new CardinalDirection(CardinalDirectionType.West, new Coordinate(0.0, 50.0), Axis.X, true, false, true, false, 1.0, "cardinal_direction_west");
  static final CardinalDirection NorthWest = new CardinalDirection(CardinalDirectionType.NorthWest, new Coordinate(0.0, 0.0), null, true, true, true, true, null, "cardinal_direction_northwest");

  /** All direction values */
  static final Iterable<CardinalDirection> all = [North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest];

  /** Cardinal directions */
  static final Iterable<CardinalDirection> cardinal = [North, East, South, West];

  /** Ordinal directions */
  static final Iterable<CardinalDirection> intercardinal = [NorthEast, SouthEast, SouthWest, NorthWest];

  /** Horizontal directions */
  static final Iterable<CardinalDirection> horizontal = [East, West];

  /** Vertical directions */
  static final Iterable<CardinalDirection> vertical = [North, South];

  /** Cardinal direction type */
  final CardinalDirectionType type;

  /** Coordinate point where this appears, typically in resize UIs */
  final Coordinate point;

  /** Cardinal axis (intercardinal directions are excluded, use API below) */
  final Axis? axis;

  /** Is on horizontal axis */
  final bool horizontalAxis;

  /** Is on vertical axis */
  final bool verticalAxis;

  /** Whether cardinal direction value is west- or north- facing */
  final bool west;

  /** Whether cardinal direction value is west- or north- facing */
  final bool north;

  /** Multiplier based on direction useful to eliminate switches in logic. */
  final double? direction;

  /** Name of cardinal direction */
  final String name;

  CardinalDirection(CardinalDirectionType this.type, Coordinate this.point, Axis? this.axis, bool this.horizontalAxis, bool this.verticalAxis, bool this.west, bool this.north, double? this.direction, String this.name);

  bool get westOrNorth
  {
    return west || north;
  }
}
