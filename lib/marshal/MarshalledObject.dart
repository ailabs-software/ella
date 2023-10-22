import "dart:collection";
import "dart:convert";
import "package:ella/ella.dart";
import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/exception/IllegalStateException.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/ISerialisableDeserialisable.dart";
import "package:ella/marshal/ISerialisableValueMarshallerFunction.dart";
import "package:ella/marshal/IValueMarshallerFunction.dart";
import "package:ella/marshal/IUnmarshalFactory.dart";
import "package:ella/marshal/MarshalledArray.dart";
import "package:ella/marshal/MarshalledMapKeyPhase.dart";

/** @fileoverview
      Represents an object as a map where each field is a string so that it is suitable for serialisation.
      Idea of ella's serialisation framework: Caller provides the type information, via either a factory or calling a specialized method. */

class MarshalledObject implements ISerialisable
{
  Object? _rawValue;

  MarshalledObject(Object? rawValue)
  {
    this._rawValue = rawValue;
  }

  MarshalledObject.emptyObject()
  {
    this._rawValue = new Map<String, dynamic>();
  }

  MarshalledObject.emptyArray()
  {
    this._rawValue = <Object?>[];
  }

  /** Factory that marshals an ISerialisable object */
  factory MarshalledObject.marshal(ISerialisable object)
  {
    MarshalledObject marshaledObject = new MarshalledObject.emptyObject();
    object.marshal(marshaledObject);
    return marshaledObject;
  }

  /** Constructor to create from Dart object. Will marshal all Dart object recursively! */
  MarshalledObject.fromDartObject(Object? dartObject)
  {
    this._rawValue = _marshalRecursively(dartObject).getRawValue();
  }

  static MarshalledObject _marshalRecursively(Object? payload)
  {
    MarshalledObject marshaledObject;
    // Determines type of object, properly converts to intermediate format, then encodes.
    if (payload is Future) {
      throw new IllegalArgumentException("Cannot marshal a Future!");
    }
    else if (payload is Map) {
      marshaledObject = marshalSimpleMap(payload);
    }
    else if (payload is List) {
      marshaledObject = marshalList(payload).toObject();
    }
    else if (payload is Enum) {
      marshaledObject = new MarshalledObject(payload.index);
    }
    else if (payload is ISerialisable) {
      marshaledObject = new MarshalledObject.emptyObject();
      payload.marshal(marshaledObject);
    }
    else {
      marshaledObject = new MarshalledObject(payload);
    }
    return marshaledObject;
  }

  static MarshalledArray marshalList(List<Object?> payload)
  {
    MarshalledArray marshaledArray = new MarshalledObject.emptyArray().asArray();
    for (Object? element in payload)
    {
      /** Recursively marshal list */
      marshaledArray.pushElement( _marshalRecursively(element).getRawValue() );
    }
    return marshaledArray;
  }

  static MarshalledObject marshalSimpleMap(Map<Object?, Object?> payload)
  {
    MarshalledObject marshaledObject = new MarshalledObject.emptyObject();
    for (Object? key in payload.keys)
    {
      /** Recursively encode map using setMapKey() so that fields with null values are preserved. */
      marshaledObject._setMapKey(key.toString(), _marshalRecursively(payload[key]).getRawValue() );
    }
    return marshaledObject;
  }

  // Implement ISerialisable.marshal so MarshalledObject can be used itself as ISerialisable.
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled._rawValue = _rawValue;
  }

  MarshalledObject createObjectProperty(String property)
  {
    MarshalledObject newObj = new MarshalledObject.emptyObject();
    setPropertyFromMarshalledObject(property, newObj);
    return newObj;
  }

  /** Setting a property only sets field if value is non-null in order to reduce JSON payload size by excluding null properties.
   *  Don't use directly in application code. */
  void setPropertyUnsafe(String property, Object? value)
  {
    if (value != null) {
      _setMapKey(property, value);
    }
    else {
      // Avoid setting null property if is empty, so JSON is more compact.
      // This reduces size of brochure JSON by 21% by avoiding storing empty properties.
      removeProperty(property);
    }
  }

  /** Set bool property with type safety */
  void setPropertyFromBool(String property, bool? value)
  {
    setPropertyUnsafe(property, value);
  }

  /** Set int property with type safety */
  void setPropertyFromInt(String property, int? value)
  {
    // Prevent -0.0 in JS-compiled code from occurring
    // (it is mind boggling that is considered an int by Dart, as it will deserialise to a double in json.decode() )
    if (value != null) {
      value = value.toInt();
    }

    setPropertyUnsafe(property, value);
  }

  /** Set double property with type safety */
  void setPropertyFromDouble(String property, double? value)
  {
    if (value != null && value.isFinite && !value.isNaN) {
      setPropertyUnsafe(property, value);
    }
    else {
      setPropertyUnsafe(property, null);
    }
  }

  /** Set string property with type safety */
  void setPropertyFromString(String property, String? value)
  {
    setPropertyUnsafe(property, value);
  }

  /** Set property if not equal to the default value.
   *  This is useful for preventing default state from bloating saved JSON models.
   *  Object must implement == as value equality. */
  void setPropertyUnsafeIfNotDefault<T>(String property, T? defaultValue, T? value)
  {
    if (value != null &&
        value != defaultValue) {
      setPropertyUnsafe(property, value);
    }
    else {
      removeProperty(property);
    }
  }

  /** Get a property, returning null if null */
  MarshalledObject? get(String property)
  {
    MarshalledObject propertyObject = getProperty(property);
    if ( propertyObject.isNotNull() ) {
      return propertyObject;
    }
    else {
      return null;
    }
  }

  /** Get a property, throwing if not set. */
  MarshalledObject getRequired(String property)
  {
    MarshalledObject? object = get(property);
    if (object == null) {
      throw new IllegalStateException("MarshalledObject: During unmarshalling, the application tried to access '${property}' as a required property, but it was null.");
    }
    return object;
  }

  /** Get as bool or empty if null */
  bool getBool(String property)
  {
    return get(property)?.asBool() ?? false;
  }

  /** Get as int or empty if null */
  int getInt(String property)
  {
    return get(property)?.asInt() ?? 0;
  }

  /** Get as double or empty if null */
  double getDouble(String property)
  {
    return get(property)?.asDouble() ?? 0.0;
  }

  /** Get as string or empty if null */
  String getString(String property)
  {
    return get(property)?.asString() ?? ella.EMPTY_STRING;
  }

  /** Get as array or empty */
  MarshalledArray getArray(String property)
  {
    MarshalledObject? object = get(property);
    return ( object ?? new MarshalledObject.emptyArray() ).asArray();
  }

  /** Return this object as nullable type, flowing through null, if null. Used in RPC code generator to short-circuit unmarshalling logic if return type is null. */
  MarshalledObject? asNullable()
  {
    return isNull() ? null : this;
  }

  /** This method should usually not be used for checking whether a property is null. */
  bool isNull()
  {
    return this._rawValue == null;
  }

  /** This method should usually not be used for checking whether a property is not null. */
  bool isNotNull()
  {
    return this._rawValue != null;
  }

  void assertIsNotNull()
  {
    if ( isNull() ) {
      throw new IllegalStateException("Operation is unsupported because MarshalledObject's value is null.");
    }
  }

  void setFromDartObject(Object? dartObject)
  {
    this._rawValue = _marshalRecursively(dartObject).getRawValue();
  }

  void setRawValue(Object? newRawValue)
  {
    this._rawValue = newRawValue;
  }

  Object? getRawValue()
  {
    /** Cannot allow undefined as a value to be exposed to the application, as its behavior is inconsistently handled by JSON stringify. */
    return this._rawValue ?? null;
  }

  T getRawValueAs<T>()
  {
    return getRawValue() as T;
  }

  /** Conversion methods */

  Null asNull()
  {
    return null;
  }

  bool asBool()
  {
    return this._rawValue as bool == true;
  }

  int asInt()
  {
    return this._rawValue as int;
  }

  double asDouble()
  {
    return (this._rawValue as num).toDouble();
  }

  String asString()
  {
    return this._rawValue as String;
  }

  DateTime asDateTime()
  {
    return this._rawValue as DateTime;
  }

  /** As object. Provide factory with 'Class.create' idiom. */
  T asObject<T>(IUnmarshalFactory<T> objFactory)
  {
    T dartObj = objFactory(this);
    return dartObj;
  }

  /** As an enum from index (int) value. Pass the list of enum members typically called (Name of Enum).values */
  T asEnum<T>(List<T> values)
  {
    assertIsNotNull();
    int index = asInt();
    return values[index];
  }

  /** As enum frum name (string) value */
  T asEnumName<T extends Enum>(Iterable<T> values)
  {
    assertIsNotNull();
    String name = asString();
    return values.byName(name);
  }

  /** Sets property from Dart object. */
  void setPropertyFromDartObject(String property, Object? dartObject)
  {
    setPropertyUnsafe(property, _marshalRecursively(dartObject).getRawValue() );
  }

  /** Set from marshalled object property with type safety */
  void setPropertyFromMarshalledObject(String property, MarshalledObject? value)
  {
    setPropertyUnsafe(property, value?.getRawValue() );
  }

  /** Sets property from Dart iterable of serialised objects. Does not marshal. */
  void setPropertyFromMarshalledIterable(String property, Iterable<MarshalledObject> iterable)
  {
    MarshalledArray array = new MarshalledObject.emptyArray().asArray();
    array.addFromIterable(iterable);
    setPropertyUnsafe(property, array.getRawValue() );
  }

  /** Marshalling setter for convenience. */
  void setPropertyFromObjectIterable(String property, Iterable<ISerialisable> iterable)
  {
    setPropertyFromIterableMarshaller(property, iterable, MarshalledObject.marshal);
  }

  /** Marshalling setter for convenience. */
  void setPropertyFromIterableMarshaller(String property, Iterable<ISerialisable> iterable, ISerialisableValueMarshallerFunction valueMarshaller)
  {
    setPropertyFromMarshalledIterable(property, iterable.map(valueMarshaller) );
  }

  void setPropertyFromSimpleIterable(String property, Iterable<Object?> iterable)
  {
    setPropertyFromMarshalledIterable(property, iterable.map(MarshalledObject.new) );
  }

  /** Marshalling setter for convenience. */
  void setPropertyFromObject(String property, ISerialisable? value)
  {
    if (value != null) {
      setPropertyUnsafe(property, new MarshalledObject.marshal(value).getRawValue() );
    }
    else {
      removeProperty(property);
    }
  }

  /** Set property from serialisable of value is not equal to the default value.
   *  This is useful for preventing default state from bloating saved JSON models.
   *  Object must implement == as value equality .*/
  void setPropertyFromObjectIfNotDefault(String property, ISerialisable defaultValue, ISerialisable? value)
  {
    if (value != null &&
        value != defaultValue) {
      setPropertyUnsafe(property, new MarshalledObject.marshal(value).getRawValue() );
    }
    else {
      removeProperty(property);
    }
  }

  /** Set property from enum name */
  void setPropertyFromEnumName(String property, Enum value)
  {
    setPropertyUnsafe(property, value.name);
  }

  List<Object?> _castToList()
  {
    return _rawValue as List<Object?>;
  }

  Map<String, dynamic> _castToMap()
  {
    return _rawValue as Map<String, dynamic>;
  }

  void removeProperty(String property)
  {
    _castToMap().remove(property);
  }

  /** Set map key. Semantic difference from setProperty(): Will maintain the field with null value in the case of a null value */
  void _setMapKey(String key, Object? value)
  {
    _castToMap()[key] = value;
  }

  /** Copies all properties from other object to this object */
  void setPropertiesFrom(MarshalledObject other)
  {
    Iterable<String> properties = other.getProperties();

    Map<String, dynamic> rawValue = _castToMap();
    Map<String, dynamic> otherRawValue = other.getRawValueAs< Map<String, dynamic> >();

    for (String property in properties)
    {
      rawValue[property] = otherRawValue[property];
    }
  }

  void deleteProperty(String property)
  {
    _castToMap().remove(property);
  }

  bool has(String property)
  {
    return _castToMap()[property] != null;
  }

  /** Get property (returns wrapper object, even if null) */
  MarshalledObject getProperty(String property)
  {
    return new MarshalledObject( _castToMap()[property] );
  }

  List<String> getProperties()
  {
    return _castToMap().keys.toList();
  }

  /** Returns as a JS map view */
  Map<String, Object?> asJsMap()
  {
    return _castToMap();
  }

  /** Returns as map of string keys/T values (copies to convert). */
  Map<String, T> asSimpleMap<T>()
  {
    Map<String, T> map = new HashMap<String, T>();

    List<String> keys = getProperties();

    for (String key in keys)
    {
      map[key] = _castToMap()[key] as T;
    }

    return map;
  }

  /** As full-featured Java map. */
  MarshalledMapKeyPhase asComplexMap()
  {
    return new MarshalledMapKeyPhase(this);
  }

  /** Wraps as intermediate array */
  MarshalledArray asArray()
  {
    return new MarshalledArray( _castToList() );
  }

  /** Whether object is an array. */
  bool isArray()
  {
    return this._rawValue is List;
  }

  /** Whether object is a Map */
  bool isMap()
  {
    return this._rawValue is Map;
  }

  /** Whether is an object. */
  bool isObject()
  {
    return this._rawValue != null && !(this._rawValue is num) && !(this._rawValue is bool) && !(this._rawValue is String);
  }

  /** Sets property from simple map. */
  void setPropertyFromSimpleMap(String property, Map<String, Object?>? mapObject)
  {
    if (mapObject != null) {
      setPropertyUnsafe(property, marshalSimpleMap(mapObject).getRawValue() );
    }
    else {
      removeProperty(property);
    }
  }

  /** Sets property from complex map. */
  void setPropertyFromComplexMap(String property, Map? mapObject, IValueMarshallerFunction keyMarshaller, IValueMarshallerFunction valueMarshaller)
  {
    if (mapObject != null) {
      setPropertyUnsafe(property, marshalComplexMap(mapObject, keyMarshaller, valueMarshaller).getRawValue() );
    }
    else {
      removeProperty(property);
    }
  }

  /** Compare two maps */
  bool _objectEquals(MarshalledObject other)
  {
    Set<String> superKeys = new Set<String>();
    superKeys.addAll( getProperties() );
    superKeys.addAll( other.getProperties() );
    for (String key in superKeys)
    {
      if ( !getProperty(key).equals( other.getProperty(key) ) ) {
        return false;
      }
    }
    return true; // All keys equal.
  }

  /** Structurally compares object for equality. */
  bool equals(MarshalledObject? other)
  {
    if (other == null) {
      return false;
    }

    if ( isNull() || other.isNull() ) {
      return isNull() == other.isNull();
    }

    if ( isArray() || other.isArray() ) {
      if ( isArray() != other.isArray() ) {
        return false;
      }
      return asArray().equals( other.asArray() );
    }

    if ( isObject() || other.isObject() ) {
      if ( isObject() != other.isObject() ) {
        return false;
      }
      return _objectEquals(other);
    }

    return getRawValue() == other.getRawValue();
  }

  /** Deep clones object which is serialisable. */
  MarshalledObject deepClone()
  {
    String serialisedString = json.encode(_rawValue);
    return new MarshalledObject( json.decode(serialisedString) );
  }

  /** Helper method. Is a SerialisableValueMarshallerFunction function. Used to marshal when deserialiser code knows statically the type. */
  static MarshalledObject marshalValue(Object? value)
  {
    if (value is ISerialisable) {
      return marshalObject(value);
    }
    else if (value == null || value is num || value is bool || value is String) {
      return new MarshalledObject(value); // Language built-in type.
    }
    else {
      throw new Exception("Cannot marshal this value type, is not built-in or ISerialisable: " + value.runtimeType.toString() );
    }
  }

  /** Helper method for serialisaing Dart objects */
  static MarshalledObject marshalDartValue(Object? value)
  {
    return new MarshalledObject.fromDartObject(value);
  }

  /** Helper method. */
  static MarshalledObject marshalObject(ISerialisable object)
  {
    return new MarshalledObject.marshal(object);
  }

  /** Helper method. */
  static MarshalledObject marshalComplexMap(Map mapObject, IValueMarshallerFunction keyMarshaller, IValueMarshallerFunction valueMarshaller)
  {
    MarshalledObject marshalledMap = new MarshalledObject.emptyArray();
    MarshalledArray arrayAccessor = marshalledMap.asArray();

    /** serialise each key/value pair. */
    for (Object? key in mapObject.keys)
    {
      // Marshal key in odd position.
      arrayAccessor.pushElement( keyMarshaller(key).getRawValue() );
      // Marshal value in even position.
      arrayAccessor.pushElement( valueMarshaller( mapObject[key] ).getRawValue() );
    }

    return marshalledMap;
  }

  /** Internal method for copying serialisable objects */
  static MarshalledObject _getDeepClonedEncodedObject<T extends ISerialisable>(T serialisableObject)
  {
    MarshalledObject marshalled = new MarshalledObject.emptyObject();
    serialisableObject.marshal(marshalled);
    marshalled = marshalled.deepClone(); // Make a deep clone to ensure no values are shared.
    return marshalled;
  }

  /** Util method for copying serialisable objects via serialisation/deserialisation cycle. */
  static T copySerialisableObject<T extends ISerialisable>(T serialisableObject, IUnmarshalFactory<T> objFactory)
  {
    MarshalledObject marshalled = _getDeepClonedEncodedObject(serialisableObject);
    return objFactory(marshalled);
  }

  /** Util method for copying serialisable objects via serialisation/deserialisation cycle to target. */
  static T copyFromObjectToObject<T extends ISerialisableDeserialisable>(T sourceObject, T targetObject)
  {
    MarshalledObject encodedObject = _getDeepClonedEncodedObject(sourceObject);
    targetObject.unmarshalVirtual(encodedObject);
    return targetObject;
  }

  /** Unmarshal self (no-op) */
  static MarshalledObject unmarshal(MarshalledObject marshalled)
  {
    return marshalled;
  }
}
