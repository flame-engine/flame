import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/ascii.dart';
import 'package:flame_yarn/src/parse/token.dart';

/// Parses the [input] into a stream of [Token]s, according to the Yarn syntax.
List<Token> tokenize(String input) {
  return _Lexer(input).parse();
}

/// Main working class for the [tokenize] function.
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
    assert(pos == 0);
    indentStack.add(0);
    pushMode(modeMain);
    while (!eof) {
      final ok = (modeStack.last)();
      if (!ok) {
        error('invalid syntax');
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

  /// Pops the last mode from the stack and checks that it was [mode].
  void popMode(_ModeFn mode) {
    final removed = modeStack.removeLast();
    assert(removed == mode);
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
    return eatEmptyLine() ||
      eatCommentLine() ||
      pushMode(modeNodeHeader);
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

  bool modeNodeHeaderLine() {
    return eatWhitespace() ||
        (eat($colon) && pushToken(Token.colon)) ||
        eatHeaderRestOfLine();
  }

  bool modeNodeBody() {
    return eatEmptyLine() || eatCommentLine() || eatBodyEnd() || eatIndent();
  }

  bool modeNodeBodyLine() {
    return eatArrow() ||
        eatCommandStart() ||
        eatCharacterName() ||
        switchToTextMode();
  }

  bool switchToTextMode() {
    pushMode(modeText);
    return true;
  }

  bool modeText() {
    return eatTextCommentOrNewline() ||
        eatTextEscapeSequence() ||
        eatExpressionStart() ||
        eatPlainText();
  }

  bool modeExpression() {
    return eatWhitespace() ||
        eatExpressionId() ||
        eatExpressionVariable() ||
        eatNumber() ||
        eatString() ||
        eatOperator() ||
        eatExpressionEnd() ||
        eatExpressionCommandEnd();
  }

  bool modeCommand() {
    return eatWhitespace() || eatCommandName() || eatCommandEnd();
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
    } if (eatNewline()) {
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
      pushToken(Token.headerEnd);
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
    if (eat($equals) && eat($equals) && eat($equals) && eatNewline()) {
      popToken(Token.newline);
      pushToken(Token.bodyEnd);
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
    if ((cu >= $lowercaseA && cu <= $lowercaseZ) ||
        (cu >= $uppercaseA && cu <= $uppercaseZ) || cu == $underscore) {
      pos += 1;
      while (true) {
        cu = codeUnit;
        if ((cu >= $lowercaseA && cu <= $lowercaseZ) ||
            (cu >= $uppercaseA && cu <= $uppercaseZ) ||
            (cu >= $digit0 && cu <= $digit9) ||
            cu == $underscore) {
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
  /// dedent tokens according to the indent stack. After that switches to the
  /// [modeNodeBodyLine]. Always returns true (even if a line had 0 spaces).
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
    }
    if (lineIndent > indentStack.last) {
      indentStack.add(lineIndent);
      tokens.add(Token.indent);
    }
    while (lineIndent < indentStack.last) {
      indentStack.removeLast();
      tokens.add(Token.dedent);
    }
    if (lineIndent > indentStack.last) {
      throw SyntaxError('Inconsistent indentation');
    }
    pushMode(modeNodeBodyLine);
    return true;
  }

  /// Consumes an arrow token '->' and emits it.
  bool eatArrow() {
    final pos0 = pos;
    if (eat($minus) && eat($greaterThan)) {
      tokens.add(Token.arrow);
      eatWhitespace();
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes+emits a command start token '<<', and switches to the
  /// [modeCommand].
  bool eatCommandStart() {
    final pos0 = pos;
    if (eat($lessThan) && eat($lessThan)) {
      tokens.add(Token.commandStart);
      eatWhitespace();
      pushMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  bool eatCommandEnd() {
    final pos0 = pos;
    if (eat($greaterThan) && eat($greaterThan)) {
      tokens.add(Token.commandEnd);
      eatWhitespace();
      popMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes an ID at the start of the line, followed by a ':', then emits a
  /// .speaker token.
  bool eatCharacterName() {
    final numTokens = tokens.length;
    final pos0 = pos;
    if (eatId()) {
      final idToken = tokens.removeLast();
      assert(tokens.length == numTokens && idToken.type == TokenType.id);
      eatWhitespace();
      if (eat($colon)) {
        eatWhitespace();
        tokens.add(Token.speaker(idToken.content));
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
    if (eatNewline() || eatCommentLine()) {
      popMode(modeText);
      popMode(modeNodeBodyLine);
      assert(modeStack.last == modeNodeBody);
      return true;
    }
    return false;
  }

  bool eatTextEscapeSequence() {
    if (eat($backslash)) {
      if (eatNewline()) {
        eatWhitespace();
      } else {
        final cu = codeUnit;
        if (cu == $backslash ||
            cu == $slash ||
            cu == $lessThan ||
            cu == $greaterThan ||
            cu == $leftBrace ||
            cu == $rightBrace ||
            cu == $hash) {
          pos += 1;
          tokens.add(Token.text(String.fromCharCode(cu)));
        } else if (cu == $lowercaseN) {
          pos += 1;
          tokens.add(const Token.text('\n'));
        } else {
          throw SyntaxError('Invalid escape sequence');
        }
      }
      return true;
    }
    return false;
  }

  /// Consumes '{' and enters the [modeExpression].
  bool eatExpressionStart() {
    if (eat($leftBrace)) {
      tokens.add(Token.expressionStart);
      pushMode(modeExpression);
      return true;
    }
    return false;
  }

  /// Consumes '}' and leaves the [modeExpression].
  bool eatExpressionEnd() {
    if (eat($rightBrace)) {
      tokens.add(Token.expressionEnd);
      popMode(modeExpression);
      return true;
    }
    return false;
  }

  /// Consumes '>>' while in the expression mode, and leaves both the expression
  /// mode and the [modeCommand].
  bool eatExpressionCommandEnd() {
    final pos0 = pos;
    if (eat($greaterThan) && eat($greaterThan)) {
      tokens.add(Token.expressionEnd);
      tokens.add(Token.commandEnd);
      eatWhitespace();
      popMode(modeExpression);
      popMode(modeCommand);
      return true;
    }
    pos = pos0;
    return false;
  }

  bool eatPlainText() {
    final pos0 = pos;
    final cu = codeUnit;
    if (cu == $lessThan || cu == $slash) {
      pos += 1;
      tokens.add(Token.text(String.fromCharCode(cu)));
    } else {
      while (!eof) {
        final cu = codeUnit;
        if (cu == $carriageReturn ||
            cu == $lineFeed ||
            cu == $hash ||
            cu == $leftBrace ||
            cu == $slash ||
            cu == $backslash ||
            cu == $lessThan) {
          break;
        }
        pos += 1;
      }
      if (pos > pos0) {
        tokens.add(Token.text(text.substring(pos0, pos)));
      }
    }
    return pos > pos0;
  }

  /// Consumes a plain id within an expression, which is then emitted as either
  /// one of the [keywords] tokens, or as plain .id token.
  bool eatExpressionId() {
    if (eatId()) {
      final name = tokens.last.content;
      final keywordToken = keywords[name];
      if (keywordToken != null) {
        tokens.removeLast();
        tokens.add(keywordToken);
      }
      return true;
    }
    return false;
  }

  /// Consumes a variable within an expression. A variable is just a '$' sign
  /// followed by an id. Emits a .variable token.
  bool eatExpressionVariable() {
    if (eat($dollar)) {
      if (eatId()) {
        final token = tokens.removeLast();
        tokens.add(Token.variable(token.content));
        return true;
      }
      pos--;
    }
    return false;
  }

  /// Consumes a number in the form of `DIGITS (. DIGITS)?`, and emits a
  /// corresponding token.
  bool eatNumber() {
    final pos0 = pos;
    if (eatDigits()) {
      eat($dot) && eatDigits();
      tokens.add(Token.number(text.substring(pos, pos0)));
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
        tokens.add(keyword);
        return true;
      }
    }
    if (pos < text.length) {
      final op1 = text.substring(pos, pos + 1);
      final keyword = keywords[op1];
      if (keyword != null) {
        pos += 1;
        tokens.add(keyword);
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
          tokens.add(Token.string(buffer.toString()));
          return true;
        } else if (cu == $carriageReturn || cu == $lineFeed) {
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

  bool eatCommandName() {
    if (eatId()) {
      final token = tokens.removeLast();
      final name = token.content;
      if (commandsWithArgs.containsKey(name)) {
        tokens.add(commandsWithArgs[name]!);
        pushMode(modeExpression);
      } else if (commandsWithoutArgs.containsKey(name)) {
        tokens.add(commandsWithoutArgs[name]!);
      } else {
        tokens.add(Token.command(name));
        pushMode(modeExpression);
      }
      return true;
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
    '(': Token.parenStart,
    ')': Token.parenEnd,
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
    } else {
      lineFragment = '...${text.substring(pos - 36, pos + 35)}...';
      markerIndent = ' ' * 36;
    }
    final parts = [
      message,
      '>  at line $lineNumber column ${pos - lineStart}:',
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
}

typedef _ModeFn = bool Function();
