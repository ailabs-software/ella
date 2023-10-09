import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/strings/StringUtil.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview A model which can represent money. Will be wrong for yen. */

class Money implements ISerialisable
{
  static final int MAX_CENTS = 99;

  static final Money ZERO = new Money(0);

  static final int _CENTS_FORMAT_PAD_LENGTH = 2;

  final int value;

  /** Value in cents */
  Money(int this.value);

  factory Money.fromDollars(int dollars, int cents)
  {
    if (cents > MAX_CENTS) {
      throw new IllegalArgumentException("Cents value greater than MAX_CENTS.");
    }

    return new Money(dollars * 100 + cents);
  }

  int get dollars
  {
    return value ~/ 100;
  }

  int get cents
  {
    return value % 100;
  }

  bool get isZero
  {
    return value == 0;
  }

  bool get isNonZero
  {
    return value > 0;
  }

  /** Returns a approximation of many percent more than other money object, out of 100, as int */
  int getPercentageMore(Money other)
  {
    if (value + other.value == 0) {
      return 0;
    }
    else {
      return ((value - other.value) / value * 100).round();
    }
  }

  /** Returns input parameter if greater than self */
  Money min(Money minimum)
  {
    return this.value > minimum.value ? this : minimum;
  }

  /** Add money */
  Money operator +(Money other)
  {
    return new Money(value + other.value);
  }

  /** Subtract money */
  Money operator -(Money other)
  {
    return new Money(value - other.value);
  }

  /** Multiply money time quantity */
  Money operator *(int quantity)
  {
    return new Money(value * quantity);
  }

  @override
  String toString()
  {
    return "${dollars}.${ StringUtil.padNumber(cents, _CENTS_FORMAT_PAD_LENGTH) }";
  }

  @override
  int get hashCode
  {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other)
  {
    if (other is Money) {
      return other.value == value;
    }
    else {
      return false;
    }
  }

  static Money sum(Iterable<Money> amounts)
  {
    int total = 0;
    for (Money amount in amounts)
    {
      total += amount.value;
    }
    return new Money(total);
  }

  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromInt("value", value);
  }

  static Money unmarshal(MarshalledObject marshalled)
  {
    return new Money( marshalled.getRequired("value").asInt() );
  }
}
