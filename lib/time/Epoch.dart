import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/time/DateTimeSupplierObject.dart";

/** @fileoveriew Serialisable epoch-based representation of a date & time. Does not store timezone information. */

class Epoch extends DateTimeSupplierObject implements ISerialisable
{
  /** Milliseconds since epoch */
  final int epochMS;

  Epoch(int this.epochMS);

  factory Epoch.fromDateTime(DateTime dateTime)
  {
    return new Epoch(dateTime.millisecondsSinceEpoch);
  }

  static Epoch getNow()
  {
    return new Epoch.fromDateTime(new DateTime.now());
  }

  @override
  int get hashCode
  {
    return epochMS.hashCode;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is Epoch) {
      return other.epochMS == epochMS;
    }
    else {
      return false;
    }
  }

  @override
  DateTime toDateTime()
  {
    return new DateTime.fromMillisecondsSinceEpoch(epochMS, isUtc: false);
  }

  int getEpochSeconds()
  {
    return (epochMS/1000).round();
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromInt("epochMS", epochMS);
  }

  static Epoch unmarshal(MarshalledObject marshalled)
  {
    return new Epoch( marshalled.getRequired("epochMS").asInt() );
  }
}
