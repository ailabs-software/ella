
/** @fileoverview An enum of the 8 cardinal directions. Usable as constant, unline CardinalDirection. */

enum CardinalDirectionType
{
  North("north"),
  NorthEast("north_east"),
  East("east"),
  SouthEast("south_east"),
  South("south"),
  SouthWest("south_west"),
  West("west"),
  NorthWest("north_west");

  final String name;

  const CardinalDirectionType(String this.name);
}