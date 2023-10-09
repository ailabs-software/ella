
/** @fileoverview Thrown to indicate that a method has been passed an illegal or inappropriate argument. */

class IllegalArgumentException implements Exception
{
  String? message;

  IllegalArgumentException([String? this.message]);

  @override
  String toString()
  {
    return "IllegalArgumentException: " + (message ?? "(no message)");
  }
}



