import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/time/DateTimeSupplierObject.dart";
import "package:ella/time/EllaDate.dart";
import "package:ella/time/EllaTime.dart";

/** @fileoverview Data transfer object used to communicate date & time separately */

class EllaDateTime extends DateTimeSupplierObject implements ISerialisable
{
  final EllaDate date;

  final EllaTime time;

  EllaDateTime(EllaDate this.date, EllaTime this.time);

  // Construct from DateTime's date values
  factory EllaDateTime.fromDateTime(DateTime dateTime)
  {
    return new EllaDateTime(new EllaDate.fromDateTime(dateTime), new EllaTime.fromDateTime(dateTime));
  }

  // Parse ISO8601 date
  factory EllaDateTime.parse(String isoString)
  {
    return new EllaDateTime.fromDateTime( DateTime.parse(isoString) );
  }

  // Construct for now
  factory EllaDateTime.now()
  {
    return new EllaDateTime.fromDateTime( new DateTime.now() );
  }

  @override
  DateTime toDateTime()
  {
    return time.toDateTime( date.toDateTime() );
  }

  int getSecondsSinceEpoch()
  {
    return toDateTime().millisecondsSinceEpoch ~/ 1000;
  }

  EllaDateTime add(Duration duration)
  {
    return new EllaDateTime.fromDateTime( toDateTime().add(duration) );
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result =  17;
    result = 31 * result + date.hashCode;
    result = 31 * result + time.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is EllaDateTime) {
      return other.date == date &&
             other.time == time;
    }
    else {
      return false;
    }
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromObject("date", date);
    marshalled.setPropertyFromObject("time", time);
  }

  static EllaDateTime unmarshal(MarshalledObject marshalled)
  {
    EllaDateTime model = new EllaDateTime( marshalled.getRequired("date").asObject(EllaDate.unmarshal), marshalled.getRequired("time").asObject(EllaTime.unmarshal) );
    return model;
  }
}
