import 'dart:async';

import 'package:jenny/src/errors.dart';
import 'package:jenny/src/parse/ascii.dart';
import 'package:meta/meta.dart';

/// [CommandStorage] is the repository of user-defined commands known to the
/// YarnProject.
///
/// This repository is populated by the user, using commands [addCommand0],
/// [addCommand1], [addCommand2], [addCommand3], and [addDialogueCommand],
/// depending on the arity of the function that needs to be invoked. All user-
/// defined commands need to be declared before parsing any Yarn scripts.
class CommandStorage {
  CommandStorage() : _commands = {};

  final Map<String, _Cmd?> _commands;

  /// Tokens that represent valid true/false values when converting an argument
  /// into a boolean. These sets can be modified by the user.
  static Set<String> trueValues = {'true', 'yes', 'on', '+', 'T', '1'};
  static Set<String> falseValues = {'false', 'no', 'off', '-', 'F', '0'};

  /// Returns `true` if command with the given [name] has been registered.
  bool hasCommand(String name) => _commands.containsKey(name);

  /// Registers a no-arguments function [fn] as a custom yarn command [name].
  void addCommand0(String name, FutureOr<void> Function() fn) {
    _checkName(name);
    _commands[name] = _Cmd(name, const <Type>[], (List args) => fn());
  }

  /// Registers a single-argument function [fn] as a custom yarn command [name].
  void addCommand1<T1>(String name, FutureOr<void> Function(T1) fn) {
    _checkName(name);
    _commands[name] = _Cmd(name, [T1], (List args) => fn(args[0] as T1));
  }

  /// Registers a 2-arguments function [fn] as a custom yarn command [name].
  void addCommand2<T1, T2>(String name, FutureOr<void> Function(T1, T2) fn) {
    _checkName(name);
    _commands[name] =
        _Cmd(name, [T1, T2], (List args) => fn(args[0] as T1, args[1] as T2));
  }

  /// Registers a 3-arguments function [fn] as a custom yarn command [name].
  void addCommand3<T1, T2, T3>(
    String name,
    FutureOr<void> Function(T1, T2, T3) fn,
  ) {
    _checkName(name);
    _commands[name] = _Cmd(
      name,
      [T1, T2, T3],
      (List args) => fn(args[0] as T1, args[1] as T2, args[2] as T3),
    );
  }

  /// Registers a command [name] which is not backed by any Dart function.
  /// Instead, this command will be delivered directly to the dialogue views.
  void addDialogueCommand(String name) {
    _commands[name] = null;
  }

  /// Executes the command [name], passing it the arguments as a single string
  /// [argString]. The caller should check beforehand that the command with
  /// such a name exists.
  @internal
  FutureOr<void> runCommand(String name, String argString) {
    final cmd = _commands[name];
    if (cmd != null) {
      final stringArgs = ArgumentsLexer(argString).tokenize();
      final typedArgs = cmd.unpackArguments(stringArgs);
      return cmd.run(typedArgs);
    }
  }

  /// Sanity checks for whether it is valid to add a command [name].
  void _checkName(String name) {
    assert(!hasCommand(name), 'Command <<$name>> has already been defined');
    assert(!_builtinCommands.contains(name), 'Command <<$name>> is built-in');
    assert(
      _rxId.firstMatch(name) != null,
      'Command name "$name" is not an identifier',
    );
  }

  static final _rxId = RegExp(r'^[a-zA-Z_]\w*$');

  /// The list of built-in commands in Jenny; the user is not allowed to
  /// register a command with the same name. Some of the commands in the list
  /// are reserved for future use.
  static const List<String> _builtinCommands = [
    'declare',
    'else',
    'elseif',
    'endif',
    'for',
    'if',
    'jump',
    'local',
    'set',
    'stop',
    'stop',
    'wait',
    'while',
  ];
}

/// A wrapper around Dart function, which allows that function to be invoked
/// dynamically from the Yarn runtime.
class _Cmd {
  _Cmd(this.name, List<Type> types, this._wrappedFn)
      : _signature = _unpackTypes(types),
        _arguments = List<dynamic>.filled(types.length, null) {
    numTrailingBooleans =
        _signature.reversed.takeWhile((type) => type == _Type.boolean).length;
  }

  final String name;
  final List<_Type> _signature;
  final FutureOr<void> Function(List<dynamic>) _wrappedFn;
  final List<dynamic> _arguments;
  late final int numTrailingBooleans;

  FutureOr<void> run(List<dynamic> arguments) {
    return _wrappedFn(arguments);
  }

  List<dynamic> unpackArguments(List<String> stringArguments) {
    if (stringArguments.length > _arguments.length ||
        stringArguments.length + numTrailingBooleans < _arguments.length) {
      String plural(int num, String word) => '$num $word${num == 1 ? '' : 's'}';
      throw TypeError(
        'Command <<$name>> expects ${plural(_arguments.length, 'argument')} '
        'but received ${plural(stringArguments.length, 'argument')}',
      );
    }
    for (var i = 0; i < numTrailingBooleans; i++) {
      _arguments[_arguments.length - i - 1] = false;
    }
    for (var i = 0; i < stringArguments.length; i++) {
      final strValue = stringArguments[i];
      switch (_signature[i]) {
        case _Type.boolean:
          if (CommandStorage.falseValues.contains(strValue)) {
            _arguments[i] = false;
          } else if (CommandStorage.trueValues.contains(strValue)) {
            _arguments[i] = true;
          } else {
            throw TypeError(
              'Argument ${i + 1} for command <<$name>> has value "$strValue", '
              'which is not a boolean',
            );
          }
          break;
        case _Type.integer:
          final value = int.tryParse(strValue);
          if (value == null) {
            throw TypeError(
              'Argument ${i + 1} for command <<$name>> has value "$strValue", '
              'which is not integer',
            );
          }
          _arguments[i] = value;
          break;
        case _Type.double:
          final value = double.tryParse(strValue);
          if (value == null) {
            throw TypeError(
              'Argument ${i + 1} for command <<$name>> has value "$strValue", '
              'which is not a floating-point value',
            );
          }
          _arguments[i] = value;
          break;
        case _Type.numeric:
          final value = num.tryParse(strValue);
          if (value == null) {
            throw TypeError(
              'Argument ${i + 1} for command <<$name>> has value "$strValue", '
              'which is not numeric',
            );
          }
          _arguments[i] = value;
          break;
        case _Type.string:
          _arguments[i] = strValue;
          break;
      }
    }
    return _arguments;
  }

  static List<_Type> _unpackTypes(List<Type> types) {
    final result = List.filled(types.length, _Type.string);
    for (var i = 0; i < types.length; i++) {
      final expressionType = _typeMap[types[i]];
      assert(
        expressionType != null,
        'Unsupported type ${types[i]} of argument ${i + 1}',
      );
      result[i] = expressionType!;
    }
    return result;
  }

  static const Map<Type, _Type> _typeMap = {
    bool: _Type.boolean,
    int: _Type.integer,
    double: _Type.double,
    num: _Type.numeric,
    String: _Type.string,
  };
}

@visibleForTesting
class ArgumentsLexer {
  ArgumentsLexer(this.text);

  final String text;
  int position = 0;
  List<_ModeFn> modeStack = [];
  List<String> tokens = [];
  StringBuffer buffer = StringBuffer();

  List<String> tokenize() {
    pushMode(modeStartOfArgument);
    while (!eof) {
      final ok = (modeStack.last)();
      assert(ok);
    }
    if (modeStack.last == modeTextArgument) {
      if (buffer.isNotEmpty) {
        finalizeArgument();
      }
    } else if (modeStack.last == modeQuotedArgument) {
      throw DialogueError('Unterminated quoted string');
    }
    assert(modeStack.last == modeStartOfArgument);
    return tokens;
  }

  bool get eof => position >= text.length;

  int get currentCodeUnit =>
      position < text.length ? text.codeUnitAt(position) : -1;

  bool pushMode(_ModeFn mode) {
    modeStack.add(mode);
    return true;
  }

  //----------------------------------------------------------------------------

  bool modeStartOfArgument() {
    return eatWhitespace() ||
        (eatQuote() && pushMode(modeQuotedArgument)) ||
        pushMode(modeTextArgument);
  }

  bool modeTextArgument() {
    return (eatWhitespace() && finalizeArgument()) || eatCharacter();
  }

  bool modeQuotedArgument() {
    return (eatQuote() && finalizeArgument() && checkWhitespaceAfterQuote()) ||
        eatEscapedCharacter() ||
        eatCharacter();
  }

  /// Returns true if current character is a whitespace, and skips over it.
  bool eatWhitespace() {
    final ch = currentCodeUnit;
    if (ch == $space || ch == $tab) {
      position += 1;
      return true;
    }
    return false;
  }

  /// Returns true if current character is `"`, and skips over it.
  bool eatQuote() {
    if (currentCodeUnit == $doubleQuote) {
      position += 1;
      return true;
    }
    return false;
  }

  /// Consumes any character and writes it into the buffer.
  bool eatCharacter() {
    buffer.writeCharCode(currentCodeUnit);
    position += 1;
    return true;
  }

  /// Consumes an escape sequence `\\`, `\"`, or `\n` and writes the
  /// corresponding unescaped character into the buffer.
  bool eatEscapedCharacter() {
    if (currentCodeUnit == $backslash) {
      position += 1;
      final ch = currentCodeUnit;
      if (ch == $backslash || ch == $doubleQuote) {
        buffer.writeCharCode(ch);
      } else if (ch == $lowercaseN) {
        buffer.writeCharCode($lineFeed);
      } else {
        throw DialogueError(
          'Unrecognized escape sequence \\${String.fromCharCode(ch)}',
        );
      }
      position += 1;
      return true;
    }
    return false;
  }

  bool finalizeArgument() {
    tokens.add(buffer.toString());
    buffer.clear();
    modeStack.removeLast();
    assert(modeStack.last == modeStartOfArgument);
    return true;
  }

  /// Throws an error if there is no whitespace after a quoted argument.
  bool checkWhitespaceAfterQuote() {
    if (eof || eatWhitespace()) {
      return true;
    }
    throw DialogueError('Whitespace is required after a quoted argument');
  }
}

typedef _ModeFn = bool Function();

/// Similar to `ExpressionType`, but also allows `integer`.
enum _Type {
  boolean,
  integer,
  double,
  numeric,
  string,
}
