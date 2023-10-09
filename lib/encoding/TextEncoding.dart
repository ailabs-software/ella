import "package:ella/encoding/IEncoding.dart";

/** @fileoverview This is TextEncoding, which is used by HttpClient when no deserialization or serialization is appropriate */

class TextEncoding implements IEncoding<String, String>
{
  /** Singleton instance. */
  static final TextEncoding instance = new TextEncoding();

  /** Encode */
  @override
  String encode(String payload)
  {
    return payload;
  }

  /** Decode */
  @override
  String decode(String encodedPayload)
  {
    return encodedPayload;
  }

  /**  Provide MIME type */
  @override
  String getContentType()
  {
    return "text/plain";
  }
}


