import "package:ella/encoding/IEncoding.dart";

/** @fileoverview This is XmlEncoding, which is used by HttpClient for XML type */

class XmlEncoding implements IEncoding<String, String>
{
  /** Singleton instance. */
  static final XmlEncoding instance = new XmlEncoding();

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
    return "application/xml";
  }
}
