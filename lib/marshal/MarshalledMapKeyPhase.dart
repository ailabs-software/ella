import "package:ella/marshal/IUnmarshalFactory.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/marshal/MarshalledArray.dart";
import "package:ella/marshal/MarshalledMapValuePhase.dart";

/** @fileoverview Only used on types which are intermediate objects.
 *    Idea of ella's serialization framework: Caller provides the type information, via either a factory or calling a specialized method.
 */

class MarshalledMapKeyPhase
{
  /** Wrapped JS map */
  late MarshalledArray _nativeMap;

  MarshalledMapKeyPhase(MarshalledObject nativeMap)
  {
    // Clone first, as will mutate underlying property during conversion of keys.
    this._nativeMap = nativeMap.asArray().clone();
  }

  /** Conversion methods which delegate to MarshalledObject */

  /** As object. Provide factory with 'Class.unmarshal' idiom. */
  MarshalledMapValuePhase<T> asObject<T>(IUnmarshalFactory<T> objFactory)
  {
    // Deserialize keys using this object unmarshaller.
    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      _nativeMap.set(i, objFactory( _nativeMap.get(i) ) );
    }

    // Delegate to value phase.
    return new MarshalledMapValuePhase<T>(_nativeMap);
  }

 /** As string. */
  MarshalledMapValuePhase<String> asString()
  {
    // Deserialize keys using this object unmarshaller.
    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      _nativeMap.set(i, _nativeMap.get(i).asString() );
    }

    // Delegate to value phase.
    return new MarshalledMapValuePhase<String>(_nativeMap);
  }

  /** As int. */
  MarshalledMapValuePhase<int> asInt()
  {
    // Deserialize keys using this object unmarshaller.
    for (int i = 0; i < _nativeMap.size(); i += 2)
    {
      _nativeMap.set(i, _nativeMap.get(i).asInt() );
    }

    // Delegate to value phase.
    return new MarshalledMapValuePhase<int>(_nativeMap);
  }
}

