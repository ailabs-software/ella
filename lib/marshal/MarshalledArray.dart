import "package:ella/exception/NotImplementedException.dart";
import "package:ella/marshal/IArrayMapFunction.dart";
import "package:ella/marshal/IUnmarshalFactory.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview This as a platform-independent interface for a marshalled object.
 *                This enables sharing of ISerialisable objects with Dart VM/Dart native compiled code.
 *    Only used on types which are intermediate objects.
 *    Idea of ella's serialisation framework: Caller provides the type information, via either a factory or calling a specialized method.
 */

class MarshalledArray
{
  /** Wrapped array */
  final List<Object?> _array;

  MarshalledArray(List<Object?> this._array);

  List<Object?> getRawList()
  {
    return _array;
  }

  int size()
  {
    return _array.length;
  }

  MarshalledObject get(int i)
  {
    return new MarshalledObject(_array[i]);
  }

  void set(int i, dynamic value)
  {
    _array[i] = value;
  }

  void pushElement(Object? element)
  {
    _array.add(element);
  }

  /** Clone array. (Shallow clone). */
  MarshalledArray clone()
  {
    return new MarshalledArray( new List.from(_array) );
  }

  /** As dynamic: Expects that values are serialised using DynamicValueserialiser. */
  List<dynamic> asDynamic()
  {
    throw new NotImplementedException();
  }

  Object? getRawValue()
  {
    return this._array;
  }

  /** To object */
  MarshalledObject toObject()
  {
    return new MarshalledObject(_array);
  }

  void addFromIterable(Iterable<MarshalledObject> iterable)
  {
    for (MarshalledObject element in iterable)
    {
      pushElement( element.getRawValue() );
    }
  }

  /** Conversion methods which delegate to MarshalledObject */

  List<bool> asBool()
  {
    List<bool> collector = [];

    for (int i=0; i < size(); i++)
    {
      collector.add( get(i).asBool() );
    }

    return collector;
  }

  List<int> asInt()
  {
    List<int> collector = <int>[];

    for (int i=0; i < size(); i++)
    {
      collector.add( get(i).asInt() );
    }

    return collector;
  }

  List<double> asDouble()
  {
    List<double> collector = [];

    for (int i=0; i < size(); i++)
    {
      collector.add( get(i).asDouble() );
    }

    return collector;
  }

  List<String> asString()
  {
    List<String> collector = [];

    for (int i=0; i < size(); i++)
    {
      collector.add( get(i).asString() );
    }

    return collector;
  }

  /** As object */
  List<T> asObject<T>(IUnmarshalFactory<T> objFactory)
  {
    return map<T>( (MarshalledObject obj) => obj.asObject(objFactory)! );
  }

  /** As raw */
  List<dynamic> asRaw()
  {
    List<Object?> collector = [];

    for (int i=0; i < size(); i++)
    {
      collector.add( get(i).getRawValue() );
    }

    return collector;
  }

  /** Map (helper method) */
  List<T> map<T>(IArrayMapFunction<T> mapFunction)
  {
    List<T> collector = [];

    for (int i=0; i < size(); i++)
    {
      collector.add( mapFunction( get(i) ) );
    }

    return collector;
  }

  /** Map array elements to the specified string field. Throws if field is null. */
  Iterable<String> mapStringField(String field) sync*
  {
    int l = size();
    for (int i=0; i < l; i++)
    {
      yield get(i).getRequired(field).asString();
    }
  }

  /** Map array elements to the specified int field. Throws if field is null. */
  Iterable<int> mapIntField(String field) sync*
  {
    int l = size();
    for (int i=0; i < l; i++)
    {
      yield get(i).getRequired(field).asInt();
    }
  }

  /** Get list of intermediate objects */
  List<MarshalledObject> toList()
  {
    return map( (MarshalledObject obj) => obj );
  }

  /** Compare lists */
  bool equals(MarshalledArray other)
  {
    if ( size() != other.size() ) {
      return false;
    }

    int l = size();
    for (int i = 0; i < l; i++)
    {
      if ( !get(i).equals( other.get(i) ) ) {
        return false; // Not equal
      }
    }
    return true;
  }
}
