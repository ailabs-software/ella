
/** @fileoverview @interface for encoding
 * T -- Encoded type
 * D -- Decoded type
 */

abstract class IEncoding<T, D>
{
  /** Encode */
  T encode(D payload);

  /** Decode */
  D decode(T encodedPayload);

  /**  Provide MIME type */
  String? getContentType();
}
