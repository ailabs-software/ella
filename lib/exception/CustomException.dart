
/** @fileoverview An exception which shows message exactly as passed to constructor. */

class CustomException implements Exception
{
  String message;

  CustomException(String this.message);

  @override
  String toString()
  {
    return message;
  }
}



