import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Interface used for generally a static method called unmarshal(MarshalledObject) which returns an ISerialisable object. */

typedef T IUnmarshalFactory<T>(MarshalledObject marshalled);


