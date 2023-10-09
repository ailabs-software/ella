import "package:meta/meta.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/encoding/IEncoding.dart";

/** @fileoverview An abstract class for an encoder.
 *    Converts object to intermediate representation using serdes package, then allows subclass to encode to final format (such as XML or JSON).
 *   REMEMBER: API is asymmetric. We can encode the Dart object, but can't decode back to a Dart object, so client must help with final decode back to format.
*/

abstract class AbstractEncoding<T> implements IEncoding<T, MarshalledObject>
{
  /** We provide all serialization from Object to T. */
  @override
  T encode(MarshalledObject payload)
  {
    return fromIntermediateToFormat(payload);
  }

  /** Convenience to encode a Dart object */
  T encodeDartObject(Object? dartObject)
  {
    return encode( new MarshalledObject.fromDartObject(dartObject) );
  }

  /** Asymmetric: It is necessary for the client to provide context to deserialize back to Object. */
  @override
  MarshalledObject decode(T encodedPayload)
  {
    return toIntermediateFromFormat(encodedPayload);
  }

  /** abstract method */
  @protected MarshalledObject toIntermediateFromFormat(T encodedPayload);

  /** abstract method */
  @protected T fromIntermediateToFormat(MarshalledObject intermediateFormat);

  /** abstract method: Provide MIME type */
  @override
  String getContentType();
}



