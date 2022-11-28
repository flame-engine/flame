import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/structure/expressions/functions/user_defined_function.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:meta/meta.dart';

/// [FunctionStorage] is the container for all user-defined functions in a yarn
/// project.
///
/// This repository is populates by the user, with methods [addFunction0],
/// [addFunction1], [addFunction2], [addFunction3], [addFunction4], depending
/// on the number of arguments of the function.
///
/// A function can be registered as a user-defined function if it satisfies the
/// following conditions:
/// - its return type is one of `int`, `double`, `num`, `bool`, or `String`;
/// - all its arguments have types `int`, `int?`, `double`, `double?`, `num`,
///   `num?`, `bool`, `bool?`, `String`, or `String?`;
/// - the nullable arguments must be after the non-nullable ones. These
///   arguments become optional in Yarn script, and if not provided they will
///   be passed as `null` values;
/// - the first argument in a function can also be `YarnProject`. If such
///   argument is present, then it will be passed automatically. For example,
///   if you have a function `fn(YarnProject, int)`, then it can be invoked
///   from the yarn script simply as `fn(1)`.
///
/// The functions must be added to the YarnProject before parsing the yarn
/// scripts, since the parser would throw an error if it sees a function which
/// it does not recognize.
class FunctionStorage {
  FunctionStorage();

  /// The central repository of all functions registered in this
  /// function storage.
  final Map<String, Udf> _functions = {};

  /// Number of functions that have been registered.
  int get length => _functions.length;
  bool get isEmpty => _functions.isEmpty;
  bool get isNotEmpty => _functions.isNotEmpty;

  /// Returns `true` if function with the given [name] has been registered.
  bool hasFunction(String name) => _functions.containsKey(name);

  /// Registers a no-arguments function [fn] as a custom yarn function [name].
  void addFunction0<T0>(String name, T0 Function() fn) {
    _checkName(name);
    _functions[name] = Udf(name, T0, [], (args) => fn());
  }

  /// Registers a single-argument function [fn] with the given [name].
  void addFunction1<T0, T1>(String name, T0 Function(T1) fn) {
    _checkName(name);
    _functions[name] = Udf(name, T0, [T1], (args) => fn(args[0] as T1));
  }

  /// Registers a two-argument function [fn] with the given [name].
  void addFunction2<T0, T1, T2>(String name, T0 Function(T1, T2) fn) {
    _checkName(name);
    _functions[name] =
        Udf(name, T0, [T1, T2], (args) => fn(args[0] as T1, args[1] as T2));
  }

  /// Registers a three-argument function [fn] with the given [name].
  void addFunction3<T0, T1, T2, T3>(String name, T0 Function(T1, T2, T3) fn) {
    _checkName(name);
    _functions[name] = Udf(
      name,
      T0,
      [T1, T2, T3],
      (args) => fn(args[0] as T1, args[1] as T2, args[2] as T3),
    );
  }

  /// Registers a four-argument function [fn] with the given [name].
  void addFunction4<T0, T1, T2, T3, T4>(
    String name,
    T0 Function(T1, T2, T3, T4) fn,
  ) {
    _checkName(name);
    _functions[name] = Udf(
      name,
      T0,
      [T1, T2, T3, T4],
      (args) => fn(args[0] as T1, args[1] as T2, args[2] as T3, args[3] as T4),
    );
  }

  /// Returns a builder capable of creating function expressions. This method
  /// is used by <parse.dart>.
  @internal
  FunctionBuilder? builderForFunction(String name) {
    if (!hasFunction(name)) {
      return null;
    }
    final function = _functions[name]!;
    return (List<FunctionArgument> args, YarnProject yarn, ErrorFn errorFn) {
      final arguments = function.checkAndUnpackArguments(args, errorFn);
      function.useYarnProject(yarn);
      switch (function.returnType) {
        case ExpressionType.boolean:
          return BooleanUserDefinedFn(function, arguments);
        case ExpressionType.numeric:
          return NumericUserDefinedFn(function, arguments);
        case ExpressionType.string:
          return StringUserDefinedFn(function, arguments);
        default:
          throw AssertionError('Bad return type'); // coverage:ignore-line
      }
    };
  }

  /// Sanity checks for whether it is valid to add a function [name].
  void _checkName(String name) {
    assert(!hasFunction(name), 'Function $name() has already been defined');
    assert(
      !builtinFunctions.containsKey(name),
      'Function $name() is built-in',
    );
    assert(
      _rxId.firstMatch(name) != null,
      'Function name "$name" is not an identifier',
    );
  }

  /// Regular expression that matches a valid identifier.
  static final _rxId = RegExp(r'^[a-zA-Z_]\w*$');
}

/// Wrapper for a user-provided function.
///
/// This wrapper encapsulates the knowledge about the function signature, and
/// is capable of executing the underlying function given a plain list of
@internal
class Udf {
  Udf(this.name, Type returnType, List<Type> types, this._wrappedFn)
      : _returnType = _convertReturnType(returnType),
        _argumentTypes = _convertArgumentTypes(types),
        _nOptionalArguments = _countOptionalArguments(types),
        _preparedArguments = List<dynamic>.filled(types.length, null);

  final String name;
  final ExpressionType _returnType;
  final List<_Type> _argumentTypes;
  final int _nOptionalArguments;
  final dynamic Function(List<dynamic>) _wrappedFn;
  final List<dynamic> _preparedArguments;

  ExpressionType get returnType => _returnType;

  bool get hasYarnProjectArgument =>
      _argumentTypes.isNotEmpty && _argumentTypes[0] == _Type.yarn;

  void useYarnProject(YarnProject yarn) {
    if (hasYarnProjectArgument) {
      _preparedArguments[0] = yarn;
    }
  }

  List<Expression> checkAndUnpackArguments(
    List<FunctionArgument> args,
    ErrorFn errorFn,
  ) {
    final i0 = hasYarnProjectArgument ? 1 : 0;
    final maxArgs = _argumentTypes.length - i0;
    final minArgs = maxArgs - _nOptionalArguments;
    if (args.length < minArgs) {
      errorFn(
        'Function $name() expects ${minArgs == maxArgs ? '' : 'at least '}'
        '${_plural(minArgs, 'argument')}',
      );
    }
    if (args.length > maxArgs) {
      errorFn(
        'Function $name() expects ${minArgs == maxArgs ? '' : 'at most '}'
        '${_plural(maxArgs, 'argument')}',
        args[maxArgs].position,
      );
    }
    final out = <Expression>[];
    for (var i = 0; i < args.length; i++) {
      final argType = args[i].expression.type;
      final expectedType = _argumentTypes[i + i0];
      final typesAreCompatible = false ||
          (argType == ExpressionType.boolean &&
              expectedType == _Type.boolean) ||
          (argType == ExpressionType.numeric &&
              (expectedType == _Type.integer ||
                  expectedType == _Type.double ||
                  expectedType == _Type.numeric)) ||
          (argType == ExpressionType.string && expectedType == _Type.string);
      if (!typesAreCompatible) {
        errorFn(
          'Invalid type for argument $i: expected ${expectedType.name} but '
          'received ${argType.name}',
          args[i].position,
        );
      }
      out.add(args[i].expression);
    }
    return out;
  }

  dynamic run(List<Expression> argExpressions) {
    final i0 = hasYarnProjectArgument ? 1 : 0;
    for (var i = i0; i < _preparedArguments.length; i++) {
      _preparedArguments[i] = null;
    }
    for (var i = 0; i < argExpressions.length; i++) {
      dynamic argValue = argExpressions[i].value;
      if (_argumentTypes[i] == _Type.integer) {
        argValue = (argValue as num).toInt();
      }
      if (_argumentTypes[i] == _Type.double) {
        argValue = (argValue as num).toDouble();
      }
      _preparedArguments[i + i0] = argValue;
    }
    final dynamic result = _wrappedFn(_preparedArguments);
    return result;
  }

  static ExpressionType _convertReturnType(Type type) {
    if (type == String) {
      return ExpressionType.string;
    } else if (type == bool) {
      return ExpressionType.boolean;
    } else if (type == int || type == double || type == num) {
      return ExpressionType.numeric;
    }
    throw TypeError(
      'Unsupported return type <$type>, expected one of: bool, int, double, '
      'num, or String',
    );
  }

  static Type _getType<T>() => T;
  static final Type _maybeInt = _getType<int?>();
  static final Type _maybeBool = _getType<bool?>();
  static final Type _maybeDouble = _getType<double?>();
  static final Type _maybeNum = _getType<num?>();
  static final Type _maybeString = _getType<String?>();

  static List<_Type> _convertArgumentTypes(List<Type> types) {
    final outTypes = <_Type>[];
    for (final type in types) {
      if (type == YarnProject) {
        if (outTypes.isNotEmpty) {
          throw TypeError(
            'Argument of type YarnProject must be the first in a function',
          );
        }
        outTypes.add(_Type.yarn);
      } else if (type == int || type == _maybeInt) {
        outTypes.add(_Type.integer);
      } else if (type == num || type == _maybeNum) {
        outTypes.add(_Type.numeric);
      } else if (type == double || type == _maybeDouble) {
        outTypes.add(_Type.double);
      } else if (type == bool || type == _maybeBool) {
        outTypes.add(_Type.boolean);
      } else if (type == String || type == _maybeString) {
        outTypes.add(_Type.string);
      } else {
        throw TypeError(
          'Unsupported type <$type> for argument at index ${outTypes.length}',
        );
      }
    }
    return outTypes;
  }

  static int _countOptionalArguments(List<Type> types) {
    var nOptionalArguments = 0;
    for (final type in types) {
      final isOptional = false ||
          (type == _maybeInt) ||
          (type == _maybeBool) ||
          (type == _maybeDouble) ||
          (type == _maybeNum) ||
          (type == _maybeString);
      if (isOptional) {
        nOptionalArguments += 1;
      } else if (nOptionalArguments > 0) {
        throw TypeError('Required arguments must come before the optional');
      }
    }
    return nOptionalArguments;
  }

  static String _plural(int num, String singular) {
    return '$num $singular${num == 1 ? '' : 's'}';
  }
}

/// Similar to `ExpressionType`, but also allows `integer` and `double`.
enum _Type {
  boolean,
  integer,
  double,
  numeric,
  string,
  yarn,
}
