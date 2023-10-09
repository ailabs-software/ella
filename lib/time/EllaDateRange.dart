import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/time/EllaDate.dart";

/** @fileoverview Date range model */

class EllaDateRange implements ISerialisable
{
  static final EllaDateRange empty = new EllaDateRange(null, null);

  final EllaDate? begin;

  final EllaDate? end;

  EllaDateRange(EllaDate? this.begin, EllaDate? this.end);

  bool get isNotEmpty
  {
    return begin != null || end != null;
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromObject("begin", begin);
    marshalled.setPropertyFromObject("end", end);
  }

  static EllaDateRange unmarshal(MarshalledObject marshalled)
  {
    return new EllaDateRange(marshalled.get("begin")?.asObject(EllaDate.unmarshal), marshalled.get("end")?.asObject(EllaDate.unmarshal) );
  }
}