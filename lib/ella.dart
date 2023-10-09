
/** @fileoverview Exports common typedefs & function binding routines. Originally inspired by `goog.bind`. */

typedef void VoidFunction();

typedef void ConsumerVoidFunction<T>(T arg1);

typedef Future<void> AsyncConsumerVoidFunction<T>(T arg1);

typedef void BinaryConsumerVoidFunction<T1, T2>(T1 arg1, T2 arg2);

typedef T SupplierFunction<T>();

typedef L ConsumerSupplierFunction<T, L>(T arg1);

typedef L BinaryConsumerSupplierFunction<T1, T2, L>(T1 arg1, T2 arg2);

typedef L TernaryConsumerSupplierFunction<T1, T2, T3, L>(T1 arg1, T2 arg2, T3 arg3);

typedef L QuaternaryConsumerSupplierFunction<T1, T2, T3, T4, L>(T1 arg1, T2 arg2, T3 arg3, T4 arg4);

typedef L QuinaryConsumerSupplierFunction<T1, T2, T3, T4, T5, L>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5);

typedef int ComparatorFunction<T>(T a, T b);

// Interface for Supplier
abstract class ISupplier<T>
{
  T supply();
}

// Interface for Consumer
abstract class IConsumer<T>
{
  void run(T input);
}

// Interface for ConsumerSupplier
abstract class IConsumerSupplier<T, L>
{
  L translate(T input);
}

// Interface that supplies text based on key provided.
abstract class IVarTextSupplier extends IConsumerSupplier<String, Future<String> >
{

}

// A supplier implementation
class EagerSupplier<T> implements ISupplier<T>
{
  final T _data;

  EagerSupplier(T this._data);

  @override
  T supply()
  {
    return _data;
  }
}

class EagerConsumerSupplier<T, L> implements IConsumerSupplier<T, L>
{
  final L _data;

  EagerConsumerSupplier(L this._data);

  @override
  L translate(T input)
  {
    return _data;
  }
}

// A good default handler when pass-through is a sane default.
class NoopConsumerSupplier<T, L> implements IConsumerSupplier<T, L>
{
  @override
  L translate(T input)
  {
    // Assumes type is compatible.
    return input as L;
  }
}

// Handles unary consumer supplier function
class _FunctionBinder<T, L>
{
  final ConsumerSupplierFunction<T, L> _function;

  final T _arg1;

  _FunctionBinder(ConsumerSupplierFunction<T, L> this._function, T this._arg1);

  L invoke()
  {
    return _function(_arg1);
  }
}

// Handles binary consumer supplier function
class _FunctionBinder2<T1, T2, L>
{
  final BinaryConsumerSupplierFunction<T1, T2, L> _function;

  final T1 _arg1;

  _FunctionBinder2(BinaryConsumerSupplierFunction<T1, T2, L> this._function, T1 this._arg1);

  L invoke(T2 arg2)
  {
    return _function(_arg1, arg2);
  }
}

// Handles ternary consumer supplier function
class _FunctionBinder3<T1, T2, T3, L>
{
  final TernaryConsumerSupplierFunction<T1, T2, T3, L> _function;

  final T1 _arg1;

  _FunctionBinder3(TernaryConsumerSupplierFunction<T1, T2, T3, L> this._function, T1 this._arg1);

  L invoke(T2 arg2, T3 arg3)
  {
    return _function(_arg1, arg2, arg3);
  }
}

// Handles quaternary consumer supplier function
class _FunctionBinder4<T1, T2, T3, T4, L>
{
  final QuaternaryConsumerSupplierFunction<T1, T2, T3, T4, L> _function;

  final T1 _arg1;

  _FunctionBinder4(QuaternaryConsumerSupplierFunction<T1, T2, T3, T4, L> this._function, T1 this._arg1);

  L invoke(T2 arg2, T3 arg3, T4 arg4)
  {
    return _function(_arg1, arg2, arg3, arg4);
  }
}

// For class minifier
class ella
{
  static const String EMPTY_STRING = "";

  static const String NULL_TEXT_LABEL = "(not set)";

  static const String DELETED_TEXT_LABEL = "(deleted)";

  static void noOp()
  {
    
  }

  static bool staticallyTrueFunction()
  {
    return true;
  }

  static void noOpVoidConsumerFunction(Object value)
  {

  }

  static Future<Null> noOpVoidAsyncConsumerFunction(Object value) async
  {

  }

  static T noOpConsumerSupplierFunction<T>(T value)
  {
    return value;
  }

  static Future<T> noOpAsyncConsumerSupplierFunction<T>(T value) async
  {
    return value;
  }

  static Null nullConsumerSupplierFunction<T>(T value)
  {
    return null;
  }

  static bool staticallyTrueConsumerSupplierFunction<T>(Object arg1)
  {
    return true;
  }

  static T toRequired<T>(T? value)
  {
    if (value == null) {
      throw new Exception("Context requires a non-nullable value, but the value is null.");
    }
    return value;
  }

  static SupplierFunction<L> bind<T, L>(ConsumerSupplierFunction<T, L> function, T arg1)
  {
    return new _FunctionBinder<T, L>(function, arg1).invoke;
  }

  static ConsumerSupplierFunction<T2, L> bind2<T1, T2, L>(BinaryConsumerSupplierFunction<T1, T2, L> function, T1 arg1)
  {
    return new _FunctionBinder2<T1, T2, L>(function, arg1).invoke;
  }

  static BinaryConsumerSupplierFunction<T2, T3, L> bind3<T1, T2, T3, L>(TernaryConsumerSupplierFunction<T1, T2, T3, L> function, T1 arg1)
  {
    return new _FunctionBinder3<T1, T2, T3, L>(function, arg1).invoke;
  }

  static TernaryConsumerSupplierFunction<T2, T3, T4, L> bind4<T1, T2, T3, T4, L>(QuaternaryConsumerSupplierFunction<T1, T2, T3, T4, L> function, T1 arg1)
  {
    return new _FunctionBinder4<T1, T2, T3, T4, L>(function, arg1).invoke;
  }
}

// --- dg5 types END ---

