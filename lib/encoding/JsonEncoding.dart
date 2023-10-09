import "dart:convert";
import "package:meta/meta.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/encoding/AbstractEncoding.dart";

/** @fileoverview Encoding for JSON */

class JsonEncoding extends AbstractEncoding<String>
{
  /** Singleton instance. */
  static final JsonEncoding instance = new JsonEncoding();

  /** abstract method */
  @override
  @protected MarshalledObject toIntermediateFromFormat(String? encodedPayload)
  {
    if (encodedPayload != null && encodedPayload.isNotEmpty) {
      return new MarshalledObject( json.decode(encodedPayload) );
    }
    else {
      return new MarshalledObject(null); // Null if empty string.
    }
  }

  /** abstract method */
  @override
  @protected String fromIntermediateToFormat(MarshalledObject intermediateFormat)
  {
    return json.encode( intermediateFormat.getRawValue() );
  }

  /**  Provide MIME type */
  @override
  String getContentType()
  {
    return "application/json";
  }
}


