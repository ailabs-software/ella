import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/time/EllaDate.dart";
import "package:ella/time/EllaDateTime.dart";

/** @fileoverview Date time range model */

class EllaDateTimeRange implements ISerialisable
{
  final EllaDateTime begin;

  final EllaDateTime end;

  EllaDateTimeRange(EllaDateTime this.begin, EllaDateTime this.end);

  bool containsDate(EllaDate date)
  {
    DateTime dateTime = date.toDateTime();
    return begin.date.toDateTime().millisecondsSinceEpoch >= dateTime.millisecondsSinceEpoch &&
           end.date.toDateTime().millisecondsSinceEpoch > dateTime.millisecondsSinceEpoch;
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result =  17;
    result = 31 * result + begin.hashCode;
    result = 31 * result + end.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is EllaDateTimeRange) {
      return other.begin == begin &&
             other.end == end;
    }
    else {
      return false;
    }
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromObject("begin", begin);
    marshalled.setPropertyFromObject("end", end);
  }

  static EllaDateTimeRange unmarshal(MarshalledObject marshalled)
  {
    return new EllaDateTimeRange(marshalled.getRequired("begin").asObject(EllaDateTime.unmarshal), marshalled.getRequired("end").asObject(EllaDateTime.unmarshal) );
  }
}
