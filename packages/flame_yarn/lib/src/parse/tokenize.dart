import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/ascii.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:meta/meta.dart';

/// Parses the [input] into a stream of [Token]s, according to the Yarn syntax.
@visibleForTesting
List<Token> tokenize(String input) {
  return _Lexer(input).parse();
}

/// Main working class for the [tokenize] function -- produces a stream of
/// [Token]s via its [parse] method.
///
/// The tokens emitted by the class follow these general considerations:
///   - Every `start*` token should have a corresponding `end*` token, properly
///     nested;
///   - Tokens `startBody`/`endBody` denote a Node body -- any content outside
///     is a Node's header;
///   - Whitespace and comments are discarded and do not produce tokens;
///   - Individual input lines within Node's header or body are separated with
///     newline tokens;
///   - The lexer is deterministic: given the same input, it should always
///     produce the same output.
class _Lexer {
  _Lexer(this.text)
      : pos = 0,
        lineNumber = 1,
        lineStart = 0,
        tokens = [],
        modeStack = [],
        indentStack = [];

  final String text;
  final List<Token> tokens;
  final List<_ModeFn> modeStack;
  final List<int> indentStack;

  /// Current parsing position, an offset within the [text].
  int pos;

  /// Current line number, for error reporting.
  int lineNumber;

  /// Offset of the start of the current line, used for error reporting.
  int lineStart;

  /// Main parsing function which handles transition between modes. This method
  /// will parse the [text] and return a list of [tokens]. This function can
  /// only be called once for the given [_Lexer] object.
  List<Token> parse() {
    assert(pos == 0 && lineNumber == 1 && lineStart == 0);
    indentStack.add(0);
    pushMode(modeMain);
    while (!eof) {
      final ok = (modeStack.last)();
      if (!ok) {
        error('invalid token');
      }
    }
    if (modeStack.length > 1) {
      error('incomplete node body');
    }
    popMode(modeMain);
    return tokens;
  }

  /// Has current parse position reached the end of file?
  bool get eof => pos == text.length;

  /// Returns the integer code unit at the current parse position, or -1 if we
  /// reached the end of input.
  int get codeUnit => eof ? -1 : text.codeUnitAt(pos);

  /// Pushes a new mode into the mode stack and returns `true`.
  bool pushMode(_ModeFn mode) {
    modeStack.add(mode);
    return true;
  }

  /// Pops the last mode from the stack, checks that it was [mode], and returns
  /// `true`.
  bool popMode(_ModeFn mode) {
    final removed = modeStack.removeLast();
    assert(removed == mode);
    return true;
  }

  /// Pushes a new token into the output and returns `true`.
  bool pushToken(Token token) {
    tokens.add(token);
    return true;
  }

  /// Pops the last token from the output stack and checks that it is equal to
  /// [token].
  void popToken(Token token) {
    final removed = tokens.removeLast();
    assert(removed == token);
  }

  //----------------------------------------------------------------------------
  // All `mode*()` methods have the [_ModeFn] signature, and are designed to be
  // put onto the mode stack. The collection of all modes and transitions
  // between them represent the lexer's Finite State Machine.
  //
  // Each `mode*()` method returns true if it was able to proceed in parsing,
  // or false if it cannot recognize the syntax. In the latter case a syntax
  // error will be thrown.
  //----------------------------------------------------------------------------

  /// Initial mode. Not much happens here -- it only consumes some whitespace
  /// and then jumps into the [modeNodeHeader]. In the future versions of Yarn
  /// they're planning to add some file-level tags here.
  bool modeMain() {
    return eatEmptyLine() || eatCommentLine() || pushMode(modeNodeHeader);
  }

  /// Parsing node header, this mode is only active at a start of a line, and
  /// after parsing an initial token, it pushes [modeNodeHeaderLine] which
  /// remains active until the end of the line.
  ///
  /// The mode switches to [modeNodeBody] upon encountering the '---' sequence.
  bool modeNodeHeader() {
    return eatEmptyLine() ||
        eatCommentLine() ||
        (eatId() && pushMode(modeNodeHeaderLine)) ||
        (eatWhitespace() && error('unexpected indentation')) ||
        eatHeaderEnd();
  }

  /// Mode which activates at each line of [modeNodeHeader] after an ID at the
  /// start of the line is consumed, and remains active until the end of the
  /// line.
  bool modeNodeHeaderLine() {
    return eatWhitespace() ||
        (eat($colon) && pushToken(Token.colon)) ||
        eatHeaderRestOfLine();
  }

  /// The top-level mode for parsing the body of a Node. This mode is active at
  /// the start of each line only, and will turn into [modeNodeBodyLine] after
  /// taking care of whitespace.
  bool modeNodeBody() {
    return eatEmptyLine() ||
        eatCommentLine() ||
        eatBodyEnd() ||
        (eatIndent() && pushMode(modeNodeBodyLine));
  }

  /// The mode for parsing regular lines of a node body. This mode is active at
  /// the beginning of the line only, where it attempts to disambiguate between
  /// what kind of line it is and then switches to either [modeCommand] or
  /// [modeText].
  bool modeNodeBodyLine() {
    return eatArrow() ||
        eatCommandStart() ||
        eatCharacterName() ||
        eatWhitespace() ||
        (eatNewline() && popMode(modeNodeBodyLine)) ||
        pushMode(modeText);
  }

  /// The mode of a regular text line within the node body. This mode will
  /// consume the input until the end of the line, and then pop back to
  /// [modeNodeBody].
  bool modeText() {
    return eatTextCommentOrNewline() ||
        eatTextEscapeSequence() ||
        eatExpressionStart() ||
        eatPlainText();
  }

  bool modeCommand() {
    return eatWhitespace() ||
        eatCommandName() ||
        eatCommandEnd() ||
        eatCommandNewline();
  }

  /// An expression within a [modeText] or [modeCommand]. Within the text, the
  /// expression is surrounded with curly braces `{ }`, inside a command the
  /// expression starts immediately after the command name and ends at `>>`.
  bool modeExpression() {
    return eatWhitespace() ||
        eatExpressionCommandEnd() ||
        eatExpressionId() ||
        eatExpressionVariable() ||
        eatNumber() ||
        eatString() ||
        eatOperator() ||
        eatExpressionEnd();
  }

  //----------------------------------------------------------------------------
  // All `eat*()` methods will attempt to consume a specific type of syntax at
  // the current parsing location. If successful, the functions will:
  //   - advance the parsing position [pos];
  //   - emit 0 or 1 token into the [tokens] token stream;
  //   - possibly pushes a new mode or pops the current mode;
  //   - return `true`.
  // Otherwise, the function will:
  //   - leave [pos] unmodified;
  //   - return `false`.
  //----------------------------------------------------------------------------

  /// Consumes a single character with code unit [cu].
  bool eat(int cu) {
    if (codeUnit == cu) {
      pos += 1;
      return true;
    }
    return false;
  }

  /// Consumes an empty line, i.e. a line consisting of whitespace only. Does
  /// not emit any tokens.
  bool eatEmptyLine() {
    final pos0 = pos;
    eatWhitespace();
    if (eof) {
      return true;
    }
    if (eatNewline()) {
      popToken(Token.newline);
      return true;
    } else {
      pos = pos0;
      return false;
    }
  }

  /// Consumes a comment line: `\s*//.*` up to and including the newline,
  /// without emitting any tokens.
  bool eatCommentLine() {
    final pos0 = pos;
    eatWhitespace();
    if (eat($slash) && eat($slash)) {
      while (!eof) {
        final cu = codeUnit;
        if (cu == $carriageReturn || cu == $lineFeed) {
          eatNewline();
          popToken(Token.newline);
          break;
        }
        pos += 1;
      }
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes all available whitespace at the current parsing position, without
  /// emitting any tokens.
  bool eatWhitespace() {
    final pos0 = pos;
    while (true) {
      final cu = codeUnit;
      if (!(cu == $space || cu == $tab)) {
        break;
      }
      pos += 1;
    }
    return pos > pos0;
  }

  /// Consumes a newline character, which can also be a Windows newline (\r\n),
  /// and emits a newline token.
  bool eatNewline() {
    final cu = codeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      pos += 1;
      if (cu == $carriageReturn && codeUnit == $lineFeed) {
        pos += 1;
      }
      tokens.add(Token.newline);
      lineNumber += 1;
      lineStart = pos;
      return true;
    }
    return false;
  }

  /// Consumes an end-of-header token '---' followed by a newline, emits a
  /// token, and switches to the [modeNodeBody].
  bool eatHeaderEnd() {
    final pos0 = pos;
    if (eat($minus) && eat($minus) && eat($minus) && eatNewline()) {
      popToken(Token.newline);
      pushToken(Token.startBody);
      popMode(modeNodeHeader);
      pushMode(modeNodeBody);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes an end-of-body token '===' followed by a newline, emits a token,
  /// and pops the current mode.
  bool eatBodyEnd() {
    final pos0 = pos;
    if (eat($equals) && eat($equals) && eat($equals)) {
      pos -= 3;
      eatIndent(); // ensures that dedent tokens are properly inserted
      pos += 3;
      if (eatNewline()) {
        popToken(Token.newline);
      } else if (!eof) {
        pos = pos0;
        return false;
      }
      pushToken(Token.endBody);
      popMode(modeNodeBody);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes a word that looks like an identifier, and emits an .id token.
  bool eatId() {
    final pos0 = pos;
    var cu = codeUnit;
    if (isAsciiIdentifierStart(cu)) {
      pos += 1;
      while (true) {
        cu = codeUnit;
        if (isAsciiIdentifierChar(cu)) {
          pos += 1;
        } else {
          break;
        }
      }
      tokens.add(Token.id(text.substring(pos0, pos)));
      return true;
    }
    return false;
  }

  /// Consumes a plain text until the end of the line and emits it as a plain
  /// text token, followed by a newline token. Always returns `true`.
  bool eatHeaderRestOfLine() {
    final pos0 = pos;
    for (; !eof; pos++) {
      final cu = codeUnit;
      if (cu == $carriageReturn || cu == $lineFeed) {
        break;
      } else if (cu == $slash && eat($slash) && eat($slash)) {
        pos -= 2;
        break;
      }
    }
    pushToken(Token.text(text.substring(pos0, pos)));
    if (!eatNewline()) {
      eatCommentLine();
      pushToken(Token.newline);
    }
    popMode(modeNodeHeaderLine);
    return true;
  }

  /// Consumes whitespace at the start of the line (if any) and emits indent/
  /// dedent tokens according to the indent stack. Always returns true (even if
  /// a line had 0 spaces).
  bool eatIndent() {
    var lineIndent = 0;
    while (true) {
      final cu = codeUnit;
      if (cu == $space) {
        lineIndent += 1;
      } else if (cu == $tab) {
        lineIndent += 4;
      } else {
        break;
      }
      pos += 1;
    }
    if (lineIndent > indentStack.last) {
      indentStack.add(lineIndent);
      tokens.add(Token.startIndent);
    }
    while (lineIndent < indentStack.last) {
      indentStack.removeLast();
      tokens.add(Token.endIndent);
    }
    if (lineIndent > indentStack.last) {
      error('inconsistent indentation');
    }
    return true;
  }

  /// Consumes an arrow token '->' and emits it.
  bool eatArrow() {
    final pos0 = pos;
    if (eat($minus) && eat($greaterThan)) {
      pushToken(Token.arrow);
      eatWhitespace();
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes+emits a command-start token '<<', and switches to the
  /// [modeCommand].
  bool eatCommandStart() {
    final pos0 = pos;
    if (eat($lessThan) && eat($lessThan)) {
      eatWhitespace();
      pushToken(Token.startCommand);
      pushMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes+emits the end-of-command token '>>', and pops the [modeCommand].
  bool eatCommandEnd() {
    final pos0 = pos;
    if (eat($greaterThan) && eat($greaterThan)) {
      eatWhitespace();
      pushToken(Token.endCommand);
      popMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes a Unicode ID at the start of the line, followed by a ':', then
  /// emits a [Token.speaker] and a [Token.colon], and also switches into the
  /// [modeText].
  ///
  /// Note: we have to consume detect both the character name and the subsequent
  /// ':' at the same time, because without the colon a simple word at a start
  /// of the line must be considered the plain text.
  bool eatCharacterName() {
    final pos0 = pos;
    final it = RuneIterator.at(text, pos);
    if (it.moveNext() && isUnicodeIdentifierStart(it.current)) {
      while (it.moveNext() && isUnicodeIdentifierChar(it.current)) {}
      pos = it.rawIndex;
      final pos1 = pos;
      eatWhitespace();
      if (eat($colon)) {
        eatWhitespace();
        pushToken(Token.speaker(text.substring(pos0, pos1)));
        pushToken(Token.colon);
        pushMode(modeText);
        return true;
      }
    }
    pos = pos0;
    return false;
  }

  /// Consumes a comment at the end of line or a newline while in the text mode,
  /// and pops the current mode so that the next line will start again at
  /// [modeNodeBody].
  bool eatTextCommentOrNewline() {
    if (eatNewline() || (eatCommentLine() && pushToken(Token.newline))) {
      popMode(modeText);
      popMode(modeNodeBodyLine);
      assert(modeStack.last == modeNodeBody);
      return true;
    }
    return false;
  }

  /// Consumes an escape syntax while in the [modeText]. An escape syntax
  /// consists of a backslash followed by the character being escaped. An error
  /// will be raised if the escaped character is invalid (e.g. '\1'). Emits a
  /// text token with the unescaped character.
  bool eatTextEscapeSequence() {
    if (eat($backslash)) {
      if (eatNewline()) {
        popToken(Token.newline);
        eatWhitespace();
      } else {
        final cu = codeUnit;
        if (cu == $backslash ||
            cu == $slash ||
            cu == $hash ||
            cu == $lessThan ||
            cu == $greaterThan ||
            cu == $leftBrace ||
            cu == $rightBrace) {
          pos += 1;
          pushToken(Token.text(String.fromCharCode(cu)));
        } else if (cu == $lowercaseN) {
          pos += 1;
          pushToken(const Token.text('\n'));
        } else {
          error('invalid escape sequence');
        }
      }
      return true;
    }
    return false;
  }

  /// Consumes '{' and enters the [modeExpression].
  bool eatExpressionStart() {
    return eat($leftBrace) &&
        pushToken(Token.startExpression) &&
        pushMode(modeExpression);
  }

  /// Consumes '}' and pops the [modeExpression] (but only when the parent mode
  /// is [modeText]).
  bool eatExpressionEnd() {
    if (eat($rightBrace)) {
      if (modeStack[modeStack.length - 2] != modeText) {
        pos -= 1;
        error('invalid token "}" within a command');
      }
      pushToken(Token.endExpression);
      popMode(modeExpression);
      return true;
    }
    return false;
  }

  /// Consumes '>>' while in the expression mode, and leaves both the expression
  /// mode and the [modeCommand].
  /// This rule is only allowed within an expression within a command mode.
  bool eatExpressionCommandEnd() {
    final pos0 = pos;
    if (eat($greaterThan) && eat($greaterThan)) {
      if (modeStack[modeStack.length - 2] != modeCommand) {
        pos -= 2;
        error('invalid token ">>" within an expression');
      }
      pushToken(Token.endExpression);
      pushToken(Token.endCommand);
      eatWhitespace();
      popMode(modeExpression);
      popMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes regular text within the [modeText]. Stops upon seeing one of the
  /// special characters such as '\n', '\r', '#', '\\', '{', '<<', or '//'.
  /// Emits the text token corresponding to the text processed.
  bool eatPlainText() {
    final pos0 = pos;
    while (!eof) {
      final cu = codeUnit;
      if (cu == $lessThan || cu == $slash) {
        pos += 1;
        if (codeUnit == cu) {
          pos -= 1;
          break;
        }
      } else if (cu == $carriageReturn ||
          cu == $lineFeed ||
          cu == $hash ||
          cu == $backslash ||
          cu == $leftBrace) {
        break;
      }
      pos += 1;
    }
    if (pos > pos0) {
      pushToken(Token.text(text.substring(pos0, pos)));
      return true;
    }
    return false;
  }

  /// Consumes a plain id within an expression, which is then emitted as either
  /// one of the [keywords] tokens, or as plain [Token.id].
  bool eatExpressionId() {
    if (eatId()) {
      final name = tokens.last.content;
      final keywordToken = keywords[name];
      if (keywordToken != null) {
        tokens.removeLast();
        pushToken(keywordToken);
      }
      return true;
    }
    return false;
  }

  /// Consumes a variable within an expression. A variable is just a '$' sign
  /// followed by an id. Emits a [Token.variable].
  bool eatExpressionVariable() {
    if (eat($dollar)) {
      if (eatId()) {
        final token = tokens.removeLast();
        pushToken(Token.variable(token.content));
        return true;
      }
      pos--;
      error('invalid variable name');
    }
    return false;
  }

  /// Consumes a number in the form of `DIGITS (. DIGITS)?`, and emits a
  /// corresponding token.
  bool eatNumber() {
    final pos0 = pos;
    if (eatDigits()) {
      eat($dot) && eatDigits();
      pushToken(Token.number(text.substring(pos0, pos)));
      return true;
    }
    return false;
  }

  /// Helper for [_eatNumber]: consumes a simple run of digits.
  bool eatDigits() {
    var found = false;
    while (!eof) {
      final cu = codeUnit;
      if (cu >= $digit0 && cu <= $digit9) {
        found = true;
        pos++;
      } else {
        break;
      }
    }
    return found;
  }

  /// Consumes one of the operators defined in the [keywords] map, and emits
  /// a corresponding token.
  bool eatOperator() {
    if (pos + 1 < text.length) {
      final op2 = text.substring(pos, pos + 2);
      final keyword = keywords[op2];
      if (keyword != null) {
        pos += 2;
        pushToken(keyword);
        return true;
      }
    }
    if (pos < text.length) {
      final op1 = text.substring(pos, pos + 1);
      final keyword = keywords[op1];
      if (keyword != null) {
        pos += 1;
        pushToken(keyword);
        return true;
      }
    }
    return false;
  }

  /// Consumes a string literal in single or double quotes and emits a .string
  /// token where all escape characters has been unescaped. Returns false if the
  /// string is invalid (for example ends without a closing quote, or contains
  /// an unknown escape sequence).
  bool eatString() {
    final pos0 = pos;
    final quote = codeUnit;
    if (quote == $doubleQuote || quote == $singleQuote) {
      final buffer = StringBuffer();
      pos += 1;
      while (!eof) {
        final cu = codeUnit;
        if (cu == quote) {
          pos += 1;
          pushToken(Token.string(buffer.toString()));
          return true;
        } else if (cu == $carriageReturn || cu == $lineFeed) {
          error('unexpected end of line while parsing a string');
          break;
        } else if (cu == $backslash) {
          pos += 1;
          final cu2 = codeUnit;
          pos += 1;
          if (cu2 == $singleQuote || cu2 == $doubleQuote || cu2 == $backslash) {
            buffer.writeCharCode(cu2);
          } else if (cu2 == $lowercaseN) {
            buffer.writeCharCode($lineFeed);
          } else {
            break;
          }
        } else {
          buffer.writeCharCode(cu);
          pos += 1;
        }
      }
    }
    pos = pos0;
    return false;
  }

  /// Consumes a name of the command (ID) and emits it as a token. After that,
  /// goes either into expression mode if the command expects arguments, or
  /// remains in the command mode otherwise. User-defined commands are assumed
  /// to always allow expressions.
  bool eatCommandName() {
    if (eatId()) {
      final token = tokens.removeLast();
      final name = token.content;
      if (commandsWithArgs.containsKey(name)) {
        pushToken(commandsWithArgs[name]!);
        pushToken(Token.startExpression);
        pushMode(modeExpression);
      } else if (commandsWithoutArgs.containsKey(name)) {
        pushToken(commandsWithoutArgs[name]!);
      } else {
        pushToken(Token.command(name));
        pushToken(Token.startExpression);
        pushMode(modeExpression);
      }
      return true;
    }
    return false;
  }

  /// Check whether a command terminated prematurely.
  bool eatCommandNewline() {
    final cu = codeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      error('missing command close token ">>"');
    }
    return false;
  }

  static const Map<String, Token> keywords = {
    'true': Token.constTrue,
    'false': Token.constFalse,
    'string': Token.typeString,
    'number': Token.typeNumber,
    'bool': Token.typeBool,
    'as': Token.as,
    'to': Token.opAssign,
    '=': Token.opAssign,
    'is': Token.opEq,
    'eq': Token.opEq,
    '==': Token.opEq,
    'neq': Token.opNe,
    'ne': Token.opNe,
    '!=': Token.opNe,
    'le': Token.opLe,
    'lte': Token.opLe,
    '<=': Token.opLe,
    'ge': Token.opGe,
    'gte': Token.opGe,
    '>=': Token.opGe,
    'lt': Token.opLt,
    '<': Token.opLt,
    'gt': Token.opGt,
    '>': Token.opGt,
    'and': Token.opAnd,
    '&&': Token.opAnd,
    'or': Token.opOr,
    '||': Token.opOr,
    'xor': Token.opXor,
    '^': Token.opXor,
    'not': Token.opNot,
    '!': Token.opNot,
    '+': Token.opPlus,
    '-': Token.opMinus,
    '*': Token.opMultiply,
    '/': Token.opDivide,
    '%': Token.opModulo,
    '+=': Token.opPlusAssign,
    '-=': Token.opMinusAssign,
    '*=': Token.opMultiplyAssign,
    '/=': Token.opDivideAssign,
    '%=': Token.opModuloAssign,
    ',': Token.comma,
    '(': Token.startParen,
    ')': Token.endParen,
  };
  static const Map<String, Token> commandsWithArgs = {
    'if': Token.commandIf,
    'elseif': Token.commandElseif,
    'set': Token.commandSet,
    'jump': Token.commandJump,
    'wait': Token.commandJump,
  };
  static const Map<String, Token> commandsWithoutArgs = {
    'else': Token.commandElse,
    'endif': Token.commandEndif,
    'stop': Token.commandStop,
  };

  /// Throws a [SyntaxError] with the given [message], augmenting it with the
  /// information about the current parsing location.
  ///
  /// The return type is bool, although the method never actually returns
  /// anything -- this is so that the method can be used in a parsing chain:
  /// ```dart
  /// eatThis() || eatThat() || error('oops, did not expect that');
  /// ```
  bool error(String message) {
    final lineEnd = findLineEnd();
    String lineFragment, markerIndent;
    if (lineEnd - lineStart <= 74) {
      lineFragment = text.substring(lineStart, lineEnd);
      markerIndent = ' ' * (pos - lineStart);
    } else if (pos - lineStart <= 50) {
      lineFragment = '${text.substring(lineStart, lineStart + 74)}...';
      markerIndent = ' ' * (pos - lineStart);
    } else if (lineEnd - pos <= 40) {
      lineFragment = '...${text.substring(lineEnd - 77, lineEnd)}';
      markerIndent = ' ' * (pos - lineEnd + 80);
    } else {
      lineFragment = '...${text.substring(pos - 36, pos + 35)}...';
      markerIndent = ' ' * 39;
    }
    final parts = [
      message,
      '>  at line $lineNumber column ${pos - lineStart + 1}:',
      '>  $lineFragment',
      '>  $markerIndent^',
      ''
    ];
    throw SyntaxError(parts.join('\n'));
  }

  /// Returns the position where the current (starting at [pos]) line ends,
  /// without altering the parsing location.
  int findLineEnd() {
    var i = pos;
    while (i < text.length) {
      final cu = text.codeUnitAt(i);
      if (cu == $lineFeed || cu == $carriageReturn) {
        break;
      }
      i += 1;
    }
    return i;
  }

  /// Is [cp] a valid code-point to start an ASCII identifier?
  static bool isAsciiIdentifierStart(int cp) {
    return (cp >= $lowercaseA && cp <= $lowercaseZ) ||
        (cp >= $uppercaseA && cp <= $uppercaseZ) ||
        cp == $underscore;
  }

  /// Is [cp] a valid code-point to continue an ASCII identifier?
  static bool isAsciiIdentifierChar(int cp) {
    return isAsciiIdentifierStart(cp) || (cp >= $digit0 && cp <= $digit9);
  }

  /// Is [cp] a valid code-point to start a Unicode identifier?
  static bool isUnicodeIdentifierStart(int cp) {
    if (cp < 0x80) {
      return isAsciiIdentifierStart(cp);
    } else if (cp <= 0x1FFF) {
      return (cp == 0xA8 || cp == 0xAA || cp == 0xAD || cp == 0xAF) ||
          (cp >= 0xB2 && cp <= 0xBE && cp != 0xB6 && cp != 0xBB) ||
          (cp >= 0xC0 && cp <= 0x2FF && cp != 0xD7 && cp != 0xF7) ||
          (cp >= 0x370 && cp <= 0x1DBF && cp != 0x1680 && cp != 0x180E) ||
          (cp >= 0x1E00 && cp <= 0x1FFF);
    } else {
      return (cp >= 0x200B && cp <= 0x200D) ||
          (cp >= 0x202A && cp <= 0x202E) ||
          (cp >= 0x203F && cp <= 0x2040) ||
          (cp == 0x2054) ||
          (cp >= 0x2060 && cp <= 0x20CF) ||
          (cp >= 0x2100 && cp <= 0x218F) ||
          (cp >= 0x2460 && cp <= 0x24FF) ||
          (cp >= 0x2776 && cp <= 0x2793) ||
          (cp >= 0x2C00 && cp <= 0x2DFF) ||
          (cp >= 0x2E80 && cp <= 0x2FFF) ||
          (cp >= 0x3004 && cp <= 0x3007) ||
          (cp >= 0x3021 && cp <= 0xD7FF && cp != 0x3030) ||
          (cp >= 0xF900 && cp <= 0xFD3D) ||
          (cp >= 0xFD40 && cp <= 0xFDCF) ||
          (cp >= 0xFDF0 && cp <= 0xFE1F) ||
          (cp >= 0xFE30 && cp <= 0xFE44) ||
          (cp >= 0xFE47 && cp <= 0xFFFD) ||
          (cp >= 0x10000 && cp <= 0xEFFFF && ((cp + 2) & 0xFFFF) >= 2);
    }
  }

  /// Is [cp] a valid code-point to continue a Unicode identifier?
  static bool isUnicodeIdentifierChar(int cp) {
    if (cp < 0x80) {
      return isAsciiIdentifierChar(cp);
    } else {
      return isUnicodeIdentifierStart(cp) ||
          (cp >= 0x300 && cp <= 0x36F) ||
          (cp >= 0x1DC0 && cp <= 0x1DFF) ||
          (cp >= 0x20D0 && cp <= 0x20FF) ||
          (cp >= 0xFE20 && cp <= 0xFE2F);
    }
  }
}

typedef _ModeFn = bool Function();
