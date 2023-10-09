import "package:meta/meta.dart";
import "package:ella/ella.dart";
import "package:ella/reclaimable/Reclaimable.dart";

/** @fileoverview Runs callback when object is reclaimed.
 *                This is useful for adding a handler that runs when a certain object is reclaimed.
 *                To use, register this object as a reclaimable of that object using [registerReclaimable()]. */

class ReclaimHandler extends Reclaimable
{
  VoidFunction _callback;

  ReclaimHandler(VoidFunction this._callback);

  @override
  @protected void reclaimInternal()
  {
    _callback();
    super.reclaimInternal();
  }
}