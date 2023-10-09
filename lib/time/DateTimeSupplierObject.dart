
/** @fileoverview Abstract type for an object which can be converted to date time. */

abstract class DateTimeSupplierObject
{
  DateTime toDateTime();

  DateTime toDateTimeAsUTC()
  {
    DateTime dateTime = toDateTime();
    return new DateTime.utc(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute, dateTime.second);
  }
}