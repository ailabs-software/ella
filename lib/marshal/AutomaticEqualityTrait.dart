import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Provides automatic equality for serialisable objects.
                  Not appropriate for objects which are used in sets or hash maps, as hash code implemenation returns a constant value. */

mixin AutomaticEqualityTrait implements ISerialisable
{
  @override
  int get hashCode
  {
    return 1996; // The same hash code is always valid but not optimal if this object is to be used in a Set or as a HashMap key.
  }

  /**
   * Compares coordinates for equality.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is ISerialisable) {
      return new MarshalledObject.fromDartObject(this).equals( new MarshalledObject.fromDartObject(other) );
    }
    else {
      return false;
    }
  }
}
