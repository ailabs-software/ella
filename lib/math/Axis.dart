import "package:ella/ella.dart";
import "package:ella/exception/IllegalStateException.dart";

/** @fileoverview Sometimes it is useful to be able to reference a coordinate axis.
 *   Also used to refer to directions as horizontal (X) and vertical (Y).
 */

class Axis
{
  /** Represents the horizontal axis. */
  static const Axis X = const Axis(0, true, false, "X");

  /** Reperesents the vertical axis. */
  static const Axis Y = const Axis(1, false, true, "Y");

  /** Some APIs want to allow selection of both axis. */
  static const Axis BOTH = const Axis(2, true, true, ella.EMPTY_STRING);

  /** Some APIs want to allow selection of neither axis */
  static const Axis NONE = const Axis(3, false, false, ella.EMPTY_STRING);

  /** Index field to provide. */
  final int index;

  /** Whether contains X component */
  final bool hasXComponent;

  /** Whether contains Y component */
  final bool hasYComponent;

  /** String name provide. */
  final String name;

  /** Const constructor. */
  const Axis(int this.index, bool this.hasXComponent, bool this.hasYComponent, String this.name);

  /** Getter. */
  Axis get oppositeAxis
  {
    switch (this)
    {
      case Axis.X:
        return Axis.Y;
      case Axis.Y:
        return Axis.X;
      default:
        throw new IllegalStateException("There is no oppositeAxis for Axis.BOTH.");
    }
  }
}


