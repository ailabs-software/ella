import "dart:async";
import "package:meta/meta.dart";
import "package:ella/reclaimable/IReclaimable.dart";
import "package:ella/object/Unique.dart";

/**
 * @fileoverview Implements the reclaimable interface. The reclaim() method is used
 * to clean up references and resources.
 * Based on Closure Library's equivalent.
 */

class Reclaimable extends Unique implements IReclaimable
{
  /**
   * Whether the object has been reclaimed of.
   * @type {bool}
   * @private
   */
  bool _reclaimed = false;

  /** Whether the object has been prepared for reclaimed (optionally used by application) */
  bool _preparedForReclaim = false;

  /** Track others to reclaim */
  List<IReclaimable>? _ownedReclaimables;

  /**
   * @return {bool} Whether the object has been reclaimed of.
   * @override
   */
  @override
  bool isReclaimed()
  {
    return _reclaimed;
  }

  /**
   * @return {bool} Whether the object has not been reclaimed of.
   * @override
   */
  @override
  bool isNotReclaimed()
  {
    return !_reclaimed;
  }

  /**
   * Reclaims of the object. If the object hasn't already been reclaimed of, calls
   * {@link #reclaimInternal}. Classes that extend {@code goog.Reclaimable} should
   * override {@link #reclaimInternal} in order to delete references to COM
   * objects, DOM nodes, and other reclaimable objects. Reentrant.
   *
   * DO NOT OVERRIDE.
   */
  @override
  void reclaim()
  {
    if (!this._reclaimed) {
      // Set reclaimed to true first, in case during the chain of disposal this
      // gets reclaimed recursively.
      this._reclaimed = true;

      _reclaimOwnedReclaimables();

      reclaimInternal();
    }
  }

  @override
  void assertReclaimed()
  {
    if (!this._reclaimed) {
      throw new Exception("Reclaimable.assertReclaimed(): This object is not reclaimed, but is expected to be.");
    }
  }

  @override
  void assertNotReclaimed()
  {
    if (this._reclaimed) {
      throw new Exception("Reclaimable.assertNotReclaimed(): Already reclaimed! There could be a listener leak.");
    }
  }

  /** Chains together objects, so when over is reclaimed, children are reclaimed
   *     Application: Component reclaim reclaims listeners as those objects are owned by component
   * Associates a reclaimable object with this object so that they will be reclaimed
   * together.
   * @param {goog.reclaimable.IReclaimable} reclaimable that will be reclaimed when
   *     this object is reclaimed.
   */
  @override
  void registerReclaimable(IReclaimable reclaimable)
  {
    if (this._reclaimed) {
      reclaimable.reclaim();
    }
    else {
      /* Many Reclaimable objects are created which will never own others, so save */
      if (this._ownedReclaimables == null) {
        this._ownedReclaimables = <IReclaimable>[];
      }
      // Add reclaimable.
      this._ownedReclaimables!.add(reclaimable);
    }
  }

  /* Removes reclaimable, so if parent is reclaimed, object provided as parameter will not be also reclaimed. */
  @override
  void unregisterReclaimable(IReclaimable reclaimable)
  {
    // Remove reclaimable.
    if ( this._ownedReclaimables == null ||
         !this._ownedReclaimables!.remove(reclaimable) ) {
      throw new Exception("Reclaimable.unregisterReclaimable(): Ownership error: Cannot unregister reclaimable we never owned.");
    }
  }

  /** Reclaimable objects disposal causes disposal of all objects it owns, so resources get cleaned up */
  void _reclaimOwnedReclaimables()
  {
    if (_ownedReclaimables != null) {
      // It is necessary to clone the list before we start traversing in order to prevent off-by-one error.
      List<IReclaimable> clonedOwnedReclaimablesList = new List.from(_ownedReclaimables!);

      for (IReclaimable ownedReclaimable in clonedOwnedReclaimablesList)
      {
        ownedReclaimable.reclaim();
      }

      _ownedReclaimables = null;
    }
  }

  /** Overridable */
  @protected void reclaimInternal()
  {
    // Default implementation is no-op
  }

  /** Disconnects the future from the the thread on this object if the object is reclaimed. */
  @protected Future<T> waitUntilReclaimed<T>(Future<T> future) async
  {
    try {
      T result = await future;
      if ( isNotReclaimed() ) {
        return result;
      }
    }
    catch (e) {
      if ( isNotReclaimed() ) {
        rethrow;
      }
    }

    // Reclaimed, so: Infinity future. Blocks forever.
    await ( new Completer<T>().future );

    throw new Exception("Never reached.");
  }

  /** Performs preparation for reclaim on all owned reclaimables once, then reclaims this object.
   *  DO NOT OVERRIDE. */
  @override
  Future<Null> beforeReclaim() async
  {
    if (!this._preparedForReclaim) {
      // Set flag to true first, in case during the chain of disposal this
      // gets reclaimed recursively.
      this._preparedForReclaim = true;

      await _beforeReclaimOwnedReclaimables();

      await beforeReclaimInternal();
    }
  }

  /** Reclaimable objects disposal causes disposal of all objects it owns, so resources get cleaned up */
  Future<Null> _beforeReclaimOwnedReclaimables() async
  {
    if (_ownedReclaimables != null) {
      // It is necessary to clone the list before we start traversing as number may change.
      List<IReclaimable> clonedOwnedReclaimablesList = new List.from(_ownedReclaimables!);

      for (IReclaimable ownedReclaimable in clonedOwnedReclaimablesList)
      {
        await ownedReclaimable.beforeReclaim();
      }
    }
  }

  /** Provide asynchronous behaviour which must execute before reclaim. */
  @protected Future<Null> beforeReclaimInternal() async
  {
    // Default implementation is no-op.
  }

  /** Reclaim iterable of reclaimables. Convenience method. */
  static void reclaimAll(Iterable<IReclaimable> reclaimables)
  {
    for (IReclaimable reclaimable in reclaimables)
    {
      reclaimable.reclaim();
    }
  }
}

