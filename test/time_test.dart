import "package:test/test.dart";
import "package:ella/time/EllaTime.dart";

void main()
{
  EllaTime simpleTime = new EllaTime.fromComponents(0, 2, 0);

  group("simple_time", () {
    setUp( () async {

    });

    test("test time components not corrupted", () async {
      EllaTime local = new EllaTime.fromComponents(23, 59, 11);
      expect(local.toSQLInterval(), "23:59:11");
    });

    test("test positive duration SQL interval", () async {
      expect(simpleTime.toSQLInterval(), "00:02:00");
    });

    test("test basic negative hours to SQL interval", () async {
      EllaTime local = new EllaTime.fromComponents(-10, 0, 0);
      expect(local.toSQLInterval(), "-10:00:00");
    });

    test("test basic negative minutes to SQL interval", () async {
      EllaTime local = new EllaTime.fromComponents(0, -2, 0);
      expect(local.toSQLInterval(), "-00:02:00");
    });

    test("test negative duration to SQL interval", () async {
      EllaTime local = simpleTime.addDays(-1);
      expect(local.toSQLInterval(), "-23:58:00");
    });

    tearDown( () async {

    });
  });
}
