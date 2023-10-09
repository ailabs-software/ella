


/** @fileoverview Reports Morning, Afternoon, Evening, Late Night, based on time. */

class TimeOfDayFormatter
{
  static final String _I18N_LATENIGHT = "Evening";
  static final String _I18N_MORNING = "Morning";
  static final String _I18N_AFTERNOON = "Afternoon";
  static final String _I18N_EVENING = "Evening";

  static String format(DateTime dateTime)
  {
    if (dateTime.hour < 6) {
      return _I18N_LATENIGHT;
    }
    if (dateTime.hour < 12) {
      return _I18N_MORNING;
    }
    if (dateTime.hour < 18) {
      return _I18N_AFTERNOON;
    }
    else {
      return _I18N_EVENING;
    }
  }
}


