import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";
import "package:ella/time/DateTimeSupplierObject.dart";

/** @fileoverview A simple date model which stores the date as 3 integers -- year, month, day */

class EllaDate extends DateTimeSupplierObject implements Comparable<EllaDate>, ISerialisable
{
  static final EllaDate empty = new EllaDate();

  final int year;

  final int month;

  final int day;

  // Zero-arg constructor sets default values.
  EllaDate([int this.year = 0, int this.month = 1, int this.day = 1]);

  // Construct from DateTime's date values
  factory EllaDate.fromDateTime(DateTime dateTime)
  {
    return new EllaDate(dateTime.year, dateTime.month, dateTime.day);
  }

  // Construct for now
  factory EllaDate.now()
  {
    return new EllaDate.fromDateTime( new DateTime.now() );
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result =  17;
    result = 31 * result + year.hashCode;
    result = 31 * result + month.hashCode;
    result = 31 * result + day.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is EllaDate) {
      return other.year == year &&
             other.month == month &&
             other.day == day;
    }
    else {
      return false;
    }
  }

  @override
  String toString()
  {
    return "${year}-${month}-${day}";
  }

  @override
  int compareTo(EllaDate other)
  {
    return toDateTime().compareTo( other.toDateTime() );
  }

  @override
  DateTime toDateTime()
  {
    return new DateTime(year, month, day);
  }

  bool isBefore(EllaDate other)
  {
    return toDateTime().isBefore( other.toDateTime() );
  }

  bool isAfter(EllaDate other)
  {
    return toDateTime().isAfter( other.toDateTime() );
  }

  /** Add days.
   *  @param value is signed int, can be negative to subtract days */
  EllaDate addDays(int value)
  {
    DateTime dateTime = new DateTime(year, month, day + value);
    return new EllaDate.fromDateTime(dateTime);
  }

  /** Add weeks.
   *  @param value is signed int, can be negative to subtract weeks */
  EllaDate addWeeks(int value)
  {
    return addDays(7 * value);
  }

  /** Add months.
   *  @param value is signed int, can be negative to subtract months */
  EllaDate addMonths(int value)
  {
    DateTime dateTime = new DateTime(year, month + value, day);
    return new EllaDate.fromDateTime(dateTime);
  }

  /** Add years.
   *  @param value is signed int, can be negative to subtract years */
  EllaDate addYears(int value)
  {
    DateTime dateTime = new DateTime(year + value, month, day);
    return new EllaDate.fromDateTime(dateTime);
  }

  /** Go to start of week */
  EllaDate startOfWeek()
  {
    DateTime dateTime = new DateTime(year, month, day - ( toDateTime().weekday - 1) );
    return new EllaDate.fromDateTime(dateTime);
  }

  /** Go to start of month */
  EllaDate startOfMonth()
  {
    return atDayOfMonth(1);
  }

  /** Go to end of month */
  EllaDate toEndOfMonth()
  {
    return atDayOfMonth(totalDaysInMonth);
  }

  /** Go to day of month */
  EllaDate atDayOfMonth(int day)
  {
    return new EllaDate(year, month, day);
  }

  /** Get whether is contained by two dates.
   *  Start must be chronologically before end. */
  bool isContainedBy(EllaDate start, EllaDate end)
  {
    DateTime dateTime = toDateTime();
    return (
      ( this == start || start.toDateTime().isBefore(dateTime) ) &&
      ( this == end || end.toDateTime().isAfter(dateTime) )
    );
  }

  /** Total days in the current month */
  int get totalDaysInMonth
  {
    DateTime lastDayInMonth = new DateTime(year, month+1, 0); // Providing a day value of zero for the next month gives you the previous month's last day.
    return lastDayInMonth.day;
  }

  /** Is today */
  bool get isToday
  {
    return EllaDate.now() == this;
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromInt("year", year);
    marshalled.setPropertyFromInt("month", month);
    marshalled.setPropertyFromInt("day", day);
  }

  /** Encoded object parameter is encoded depending on format. */
  static EllaDate unmarshal(MarshalledObject marshalled)
  {
    int year = marshalled.getRequired("year").asInt();
    int month = marshalled.getRequired("month").asInt();
    int day = marshalled.getRequired("day").asInt();
    return new EllaDate(year, month, day);
  }
}
