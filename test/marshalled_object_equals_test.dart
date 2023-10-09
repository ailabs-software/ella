import "package:test/test.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview Test for marshalled object equality */

void main()
{

  group("marshalled_object_equals", () {
    setUp( () async {

    });

    test("basic equals", () async {
      MarshalledObject a = new MarshalledObject(10);
      MarshalledObject b = new MarshalledObject(10);
      MarshalledObject c = new MarshalledObject(20);
      MarshalledObject d = new MarshalledObject(<String, int>{});
      expect(a.equals(b), true);
      expect(a.equals(c), false);
      expect(a.equals(d), false);
      expect(d.equals(d), true);
      expect(d.equals(new MarshalledObject(null)), false);
      expect(new MarshalledObject(null).equals(new MarshalledObject(null)), true);
    });

    test("map equals with differing key order are equal", () async {
      MarshalledObject a = new MarshalledObject.fromDartObject(<String, int>{"Pure Heroine": 2014, "Melodrama": 2017, "Solar Power": 2021});
      MarshalledObject b = new MarshalledObject.fromDartObject(<String, int>{"Solar Power": 2021, "Melodrama": 2017, "Pure Heroine": 2014});
      expect(a.equals(b), true);
    });

    test("map equals not equal if missing a key", () async {
      MarshalledObject a = new MarshalledObject.fromDartObject(<String, int>{"Pure Heroine": 2014, "Melodrama": 2017, "Solar Power": 2021});
      MarshalledObject b = new MarshalledObject.fromDartObject(<String, int>{"Pure Heroine": 2014, "Melodrama": 2017});
      MarshalledObject c = new MarshalledObject.fromDartObject(<String, Object>{"Pure Heroine": 2014, "Melodrama": 2017, "Solar Power": <String, int>{}});
      expect(a.equals(b), false);
      expect(a.equals(c), false);
    });

    test("list equals", () async {
      MarshalledObject a = new MarshalledObject.fromDartObject(<int>[1, 2, 3]);
      MarshalledObject b = new MarshalledObject.fromDartObject(<int>[1, 2, 3, 4]);
      expect(a.equals(b), false);
      expect(b.equals(a), false);
      expect(a.equals(a), true);
    });

    test("empty maps equal, null ignored", () async {
      MarshalledObject a = new MarshalledObject.fromDartObject(<String, Object>{});
      MarshalledObject b = new MarshalledObject.fromDartObject(<String, Object?>{"foo": null});
      expect(a.equals(b), true);
    });

    test("nested maps", () async {
      MarshalledObject a = new MarshalledObject.fromDartObject(<String, Object>{
        "data": <Object>[{"test": 1}]
      });
      MarshalledObject b = new MarshalledObject.fromDartObject(<String, Object?>{
        "data": <Object>[{"test": 1}]
      });
      expect(a.equals(b), true);
    });

    tearDown( () async {

    });
  });
}
