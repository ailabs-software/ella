import "dart:collection";
import "package:ella/marshal/IUnmarshalFactory.dart";
import "package:ella/marshal/MarshalledArray.dart";

/** @fileoverview Only used on types which are intermediate objects.
 *    Idea of ella's serialization framework: Caller provides the type information, via either a factory or calling a specialized method.
 */

class MarshalledMapValuePhase<T>
{
  /** Wrapped JS map */
  final MarshalledArray _nativeMap;

  MarshalledMapValuePhase(MarshalledArray this._nativeMap);

  /** Conversion methods which delegate to MarshalledObject. Will add more conversion methods as needed. */

  /** Performs no unmarshalling of values. */
  Map<T, dynamic> asRaw()
  {
    /** This method will convert no values. */

    return _createDartMap<T, dynamic>();
  }

  /** Casts raw values to bool. */
  Map<T, bool> asBool()
  {
    return asRaw().cast<T, bool>();
  }

  /** Casts raw values to string. */
  Map<T, String> asString()
  {
    return asRaw().cast<T, String>();
  }

  /** As object. Provide factory with 'Class.create' idiom. */
  Map<T, V> asObject<V>(IUnmarshalFactory<V> objFactory)
  {
    // Deserialize keys using this object unmarshaller.
    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      int valuePosition = i + 1; // even

      _nativeMap.set(valuePosition, objFactory( _nativeMap.get(valuePosition) ) );
    }

    return _createDartMap<T, V>();
  }

  /** As object array. */
  Map<T, List<V> > asObjectArray<V>(IUnmarshalFactory<V> objFactory)
  {
    // Deserialize keys using this object unmarshaller.
    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      int valuePosition = i + 1; // even

      _nativeMap.set(valuePosition, _nativeMap.get(valuePosition).asArray().asObject(objFactory) );
    }

    return _createDartMap<T, List<V> >();
  }

  /** Internal helper method creates Map once all values are unmarshalled.
   *  making odd-positioned elements keys and even-positioned elements values.
   */
  Map<T, V> _createDartMap<T, V>()
  {
    Map<T, V> map = new HashMap<T, V>();

    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      int keyPosition = i; // odd.
      int valuePosition = i + 1; // even.

      map[ _nativeMap.get(keyPosition).getRawValue() as T ] = _nativeMap.get(valuePosition).getRawValue() as V;
    }

    return map;
  }
}

