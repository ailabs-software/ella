import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview A method which takes a value and marshals it accordingly. */

typedef MarshalledObject ISerialisableValueMarshallerFunction(ISerialisable obj); // Stricter, requires is ISerialisable.
