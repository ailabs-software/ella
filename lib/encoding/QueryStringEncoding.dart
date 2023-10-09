import "package:ella/encoding/IEncoding.dart";

/** @fileoverview This is QueryStringEncoding, which is used by HttpClient for application/x-www-form-urlencoded type */

class QueryStringEncoding implements IEncoding<String, Map<String, String> >
{
  /** Singleton instance. */
  static final QueryStringEncoding instance = new QueryStringEncoding();

  /** Encode */
  @override
  String encode(Map<String, String> payload)
  {
    return new Uri(queryParameters: payload).query;
  }

  /** Decode */
  @override
  Map<String, String> decode(String encodedPayload)
  {
    return new Uri(query: encodedPayload).queryParameters;
  }

  /**  Provide MIME type */
  @override
  String getContentType()
  {
    return "application/x-www-form-urlencoded";
  }
}
