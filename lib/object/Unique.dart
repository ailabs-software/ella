
/** @fileoverview A uniquely identifiable object. Provides unique serial. */

class Unique
{
  static int _globalSequence_ = 0;

  // Id for this object.
  String? _uniqueObjId;

  /**
   * Gets the unique ID for the instance of this component.  If the instance
   * doesn't already have an ID, generates one on the fly.
   * @return {string} Unique component ID.
   */
  String getId()
  {
    if (_uniqueObjId == null) {
      _uniqueObjId = ( _globalSequence_++ ).toRadixString(36);
    }
    return _uniqueObjId!;
  }
}


