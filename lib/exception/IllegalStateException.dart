
/** @fileoverview Signals that a method has been invoked at an illegal or inappropriate time. In other words, the Java environment or Java application is not in an appropriate state for the requested operation. */

class IllegalStateException implements Exception
{
  String? message;

  IllegalStateException([String? this.message]);

  @override
  String toString()
  {
    return "IllegalStateException: " + (message ?? "(no message)");
  }
}
