
/** @fileoverview Whether a 12 hour time is in AM or PM */

class MeridiemMode
{
  final int index;

  final bool hasHoursAndMinutes;

  const MeridiemMode._(int this.index, bool this.hasHoursAndMinutes);

  /** Latin for before midday. */
  static const MeridiemMode AnteMeridiem = const MeridiemMode._(0, true);

  /** Latin for after (or including?) midday.*/
  static const MeridiemMode PostMeridiem = const MeridiemMode._(1, true);

  /** Special addition used to specify end-of-day, which is 24:00:00 */
  static const MeridiemMode EndOfDay = const MeridiemMode._(2, false);
}
