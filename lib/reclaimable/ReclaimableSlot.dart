import "package:ella/exception/IllegalStateException.dart";
import "package:ella/reclaimable/IReclaimable.dart";

/** @fileoverview Reclaimable slot is an object that manages a single value of type IReclaimable.
                  When the value is assigned, the previous value (if existed) is automatically reclaimed. */

class ReclaimableSlot<T extends IReclaimable>
{
  final IReclaimable _hostObject;

  T? _value;

  ReclaimableSlot(IReclaimable this._hostObject);

  void set value(T value)
  {
    if (_value != null) {
      _value!.reclaim();
    }
    _hostObject.registerReclaimable(value);
    _value = value;
  }

  T get value
  {
    if (_value == null) {
      throw new IllegalStateException("ReclaimableSlot does not yet have a value.");
    }
    return _value!;
  }
}
