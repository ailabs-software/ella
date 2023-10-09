import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Interface to implement to be serializable and deserializable.
 *
 *   This interface is used occasionally when virtual functions are desired for unmarshal.
 *
 * */

abstract class ISerialisableDeserialisable extends ISerialisable
{
  /** Sometimes, it is necessary for unmarshal to be a virtual function. */
  void unmarshalVirtual(MarshalledObject marshalled);
}
