
/**
 * @fileoverview Definition of the reclaimable interface.  A reclaimable object
 * has a reclaim method to to clean up references and resources.
 */

abstract class IReclaimable
{
  /**
  * Reclaims of the object and its resources.
  * @return {void} Nothing.
  */
  void reclaim();

  /**
  * @return {bool} Whether the object has been reclaimed of.
  */
  bool isReclaimed();

  /**
   * @return {bool} Whether the object has not been reclaimed of.
   */
  bool isNotReclaimed();

  void assertReclaimed();

  void assertNotReclaimed();

  /** Chains together objects, so when over is reclaimed, children are reclaimed
   *     Application: Component reclaim reclaims listeners as those objects are owned by component
   * Associates a reclaimable object with this object so that they will be reclaimed
   * together.
   * @param {goog.reclaimable.IReclaimable} reclaimable that will be reclaimed when
   *     this object is reclaimed.
   */
  void registerReclaimable(IReclaimable reclaimable);

  /* Removes reclaimable, so if parent is reclaimed, object provided as parameter will not be also reclaimed. */
  void unregisterReclaimable(IReclaimable reclaimable);

  /** Provide asynchronous behaviour which must execute before reclaim. */
  Future<Null> beforeReclaim();
}


