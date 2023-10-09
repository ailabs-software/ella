import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Interface to implement to be serialisable.
       @interface */
abstract class ISerialisable
{
  /** serialise to this object. */
  void marshal(MarshalledObject marshalled);

  /** NOTE: It is customary for an object implement ISerialisable to provide a method
            called unmarshal(MarshalledObject marshalled) which returns an instance of its type. */
}
