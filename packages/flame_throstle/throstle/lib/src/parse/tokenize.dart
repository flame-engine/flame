import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/ascii.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:meta/meta.dart';

/// Parses the [input] into a stream of [Token]s, according to the Yarn syntax.
@internal
List<Token> tokenize(String input, {int addErrorTokenAtIndex = -2}) {
  return _Lexer(input, addErrorTokenAtIndex).parse();
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
  _Lexer(this.text, this.addErrorTokenAtIndex)
      : position = 0,
        lineNumber = 1,
        lineStart = 0,
        tokens = [],
        modeStack = [],
        indentStack = [];

  final String text;
  final List<Token> tokens;
  final List<_ModeFn> modeStack;
  final List<int> indentStack;
  final int addErrorTokenAtIndex;

  /// Current parsing position, an offset within the [text].
  int position;

  /// Current line number, for error reporting.
  int lineNumber;

  /// Offset of the start of the current line, used for error reporting.
  int lineStart;

  /// Main parsing function which handles transition between modes. This method
  /// will parse the [text] and return a list of [tokens]. This function can
  /// only be called once for the given [_Lexer] object.
  List<Token> parse() {
    assert(position == 0 && lineNumber == 1 && lineStart == 0);
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
  bool get eof => position == text.length;

  /// Returns the integer code unit at the current parse position, or -1 if we
  /// reached the end of input.
  int get currentCodeUnit => eof ? -1 : text.codeUnitAt(position);

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
  bool pushToken(Token token, int tokenStartPosition) {
    if (tokens.length == addErrorTokenAtIndex) {
      tokens.add(Token.error(_errorMessageAtPosition(tokenStartPosition)));
    }
    tokens.add(token);
    return true;
  }

  _ModeFn get currentMode => modeStack.last;
  _ModeFn get parentMode => modeStack[modeStack.length - 2];

  /// Pops the last token from the output stack and checks that it is equal to
  /// [token].
  Token popToken([Token? token]) {
    final removed = tokens.removeLast();
    assert(token == null || removed == token);
    if (tokens.length == addErrorTokenAtIndex + 1) {
      final removed = tokens.removeLast();
      assert(removed.type == TokenType.error);
    }
    return removed;
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
        (eat($colon) && pushToken(Token.colon, position - 1)) ||
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
    return eatTextEscapeSequence() ||
        eatExpressionStart() ||
        eatPlainText() ||
        (popMode(modeText) && pushMode(modeLineEnd));
  }

  /// The command mode starts with a '<<', then consumes the command name, and
  /// after that either switches to the [modeExpression], or looks for a '>>'
  /// token to exit the mode.
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

  /// Mode at the end of a line, allows hashtags and comments.
  bool modeLineEnd() {
    assert(parentMode == modeNodeBodyLine);
    return eatWhitespace() ||
        eatCommentOrNewline() ||
        eatHashtag() ||
        eatCommandStart();
  }

  //----------------------------------------------------------------------------
  // All `eat*()` methods will attempt to consume a specific type of syntax at
  // the current parsing location. If successful, the functions will:
  //   - advance the parsing position [position];
  //   - emit 0 or more tokens into the [tokens] stream;
  //   - possibly pushes a new mode or pops the current mode;
  //   - return `true`.
  // Otherwise, the function will:
  //   - leave [position] unmodified;
  //   - return `false`.
  //----------------------------------------------------------------------------

  /// Consumes a single character with code unit [codeUnit].
  bool eat(int codeUnit) {
    if (currentCodeUnit == codeUnit) {
      position += 1;
      return true;
    }
    return false;
  }

  /// Consumes an empty line, i.e. a line consisting of whitespace only. Does
  /// not emit any tokens.
  bool eatEmptyLine() {
    final position0 = position;
    eatWhitespace();
    if (eof) {
      return true;
    }
    if (eatNewline()) {
      popToken(Token.newline);
      return true;
    } else {
      position = position0;
      return false;
    }
  }

  /// Consumes a comment line: `\s*//.*` up to and including the newline,
  /// without emitting any tokens.
  bool eatCommentLine() {
    final position0 = position;
    eatWhitespace();
    if (eat($slash) && eat($slash)) {
      while (!eof) {
        final cu = currentCodeUnit;
        if (cu == $carriageReturn || cu == $lineFeed) {
          eatNewline();
          popToken(Token.newline);
          break;
        }
        position += 1;
      }
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes all available whitespace at the current parsing position, without
  /// emitting any tokens.
  bool eatWhitespace() {
    final position0 = position;
    while (true) {
      final cu = currentCodeUnit;
      if (!(cu == $space || cu == $tab)) {
        break;
      }
      position += 1;
    }
    return position > position0;
  }

  /// Consumes a newline character, which can also be a Windows newline (\r\n),
  /// and emits a newline token.
  bool eatNewline() {
    final cu = currentCodeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      final position0 = position;
      position += 1;
      if (cu == $carriageReturn && currentCodeUnit == $lineFeed) {
        position += 1;
      }
      pushToken(Token.newline, position0);
      lineNumber += 1;
      lineStart = position;
      return true;
    }
    return false;
  }

  /// Consumes an end-of-header token '---' followed by a newline, emits a
  /// token, and switches to the [modeNodeBody].
  bool eatHeaderEnd() {
    final position0 = position;
    if (eat($minus) && eat($minus) && eat($minus) && eatNewline()) {
      popToken(Token.newline);
      pushToken(Token.startBody, position0);
      popMode(modeNodeHeader);
      pushMode(modeNodeBody);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes an end-of-body token '===' followed by a newline, emits a token,
  /// and pops the current mode.
  bool eatBodyEnd() {
    final position0 = position;
    if (eat($equals) && eat($equals) && eat($equals)) {
      position -= 3;
      eatIndent(); // ensures that dedent tokens are properly inserted
      position += 3;
      if (eatNewline()) {
        popToken(Token.newline);
      } else if (!eof) {
        position = position0;
        return false;
      }
      pushToken(Token.endBody, position0);
      popMode(modeNodeBody);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes a word that looks like an identifier, and emits an .id token.
  bool eatId() {
    final position0 = position;
    var cu = currentCodeUnit;
    if (isAsciiIdentifierStart(cu)) {
      position += 1;
      while (true) {
        cu = currentCodeUnit;
        if (isAsciiIdentifierChar(cu)) {
          position += 1;
        } else {
          break;
        }
      }
      pushToken(Token.id(text.substring(position0, position)), position0);
      return true;
    }
    return false;
  }

  /// Consumes a plain text until the end of the line and emits it as a plain
  /// text token, followed by a newline token. Always returns `true`.
  bool eatHeaderRestOfLine() {
    final position0 = position;
    for (; !eof; position++) {
      final cu = currentCodeUnit;
      if (cu == $carriageReturn || cu == $lineFeed) {
        break;
      } else if (cu == $slash && eat($slash) && eat($slash)) {
        position -= 2;
        break;
      }
    }
    pushToken(Token.text(text.substring(position0, position)), position0);
    if (!eatNewline()) {
      eatCommentLine();
      pushToken(Token.newline, position - 1);
    }
    popMode(modeNodeHeaderLine);
    return true;
  }

  /// Consumes whitespace at the start of the line (if any) and emits indent/
  /// dedent tokens according to the indent stack. Always returns true (even if
  /// a line had 0 spaces).
  bool eatIndent() {
    final position0 = position;
    var lineIndent = 0;
    while (true) {
      final cu = currentCodeUnit;
      if (cu == $space) {
        lineIndent += 1;
      } else if (cu == $tab) {
        lineIndent += 4;
      } else {
        break;
      }
      position += 1;
    }
    if (lineIndent > indentStack.last) {
      indentStack.add(lineIndent);
      pushToken(Token.startIndent, position0);
    }
    while (lineIndent < indentStack.last) {
      indentStack.removeLast();
      pushToken(Token.endIndent, position0);
    }
    if (lineIndent > indentStack.last) {
      error('inconsistent indentation');
    }
    return true;
  }

  /// Consumes an arrow token '->' and emits it.
  bool eatArrow() {
    final position0 = position;
    if (eat($minus) && eat($greaterThan)) {
      pushToken(Token.arrow, position0);
      eatWhitespace();
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes+emits a command-start token '<<', and switches to the
  /// [modeCommand].
  bool eatCommandStart() {
    final position0 = position;
    if (eat($lessThan) && eat($lessThan)) {
      eatWhitespace();
      pushToken(Token.startCommand, position0);
      pushMode(modeCommand);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes+emits the end-of-command token '>>', and pops the [modeCommand].
  bool eatCommandEnd() {
    final position0 = position;
    if (eat($greaterThan) && eat($greaterThan)) {
      eatWhitespace();
      pushToken(Token.endCommand, position0);
      popMode(modeCommand);
      if (currentMode != modeLineEnd) {
        pushMode(modeLineEnd);
      }
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes a Unicode ID at the start of the line, followed by a ':', then
  /// emits a [Token.person] and a [Token.colon], and also switches into the
  /// [modeText].
  ///
  /// Note: we have to consume detect both the character name and the subsequent
  /// ':' at the same time, because without the colon a simple word at a start
  /// of the line must be considered the plain text.
  bool eatCharacterName() {
    final position0 = position;
    final it = RuneIterator.at(text, position);
    if (it.moveNext() && isUnicodeIdentifierStart(it.current)) {
      while (it.moveNext() && isUnicodeIdentifierChar(it.current)) {}
      position = it.rawIndex;
      final position1 = position;
      eatWhitespace();
      if (eat($colon)) {
        eatWhitespace();
        final name = Token.person(text.substring(position0, position1));
        pushToken(name, position0);
        pushToken(Token.colon, position1);
        pushMode(modeText);
        return true;
      }
    }
    position = position0;
    return false;
  }

  /// Consumes a comment at the end of line or a newline while in the
  /// [modeLineEnd], and pops the current mode so that the next line will start
  /// again at [modeNodeBody].
  bool eatCommentOrNewline() {
    if (eatNewline() ||
        (eatCommentLine() && pushToken(Token.newline, position - 1))) {
      popMode(modeLineEnd);
      popMode(modeNodeBodyLine);
      assert(currentMode == modeNodeBody);
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
        final cu = currentCodeUnit;
        if (cu == $backslash ||
            cu == $slash ||
            cu == $hash ||
            cu == $lessThan ||
            cu == $greaterThan ||
            cu == $leftBrace ||
            cu == $rightBrace) {
          pushToken(Token.text(String.fromCharCode(cu)), position);
          position += 1;
        } else if (cu == $lowercaseN) {
          pushToken(const Token.text('\n'), position);
          position += 1;
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
        pushToken(Token.startExpression, position - 1) &&
        pushMode(modeExpression);
  }

  /// Consumes '}' and pops the [modeExpression] (but only when the parent mode
  /// is [modeText]).
  bool eatExpressionEnd() {
    if (eat($rightBrace)) {
      if (parentMode != modeText) {
        position -= 1;
        error('invalid token "}" within a command');
      }
      pushToken(Token.endExpression, position - 1);
      popMode(modeExpression);
      return true;
    }
    return false;
  }

  /// Consumes '>>' while in the expression mode, and leaves both the expression
  /// mode and the [modeCommand].
  /// This rule is only allowed within an expression within a command mode.
  bool eatExpressionCommandEnd() {
    final position0 = position;
    if (eat($greaterThan) && eat($greaterThan)) {
      if (parentMode != modeCommand) {
        position -= 2;
        error('invalid token ">>" within an expression');
      }
      pushToken(Token.endExpression, position0);
      pushToken(Token.endCommand, position0);
      eatWhitespace();
      popMode(modeExpression);
      popMode(modeCommand);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes regular text within the [modeText]. Stops upon seeing one of the
  /// special characters such as '\n', '\r', '#', '\\', '{', '<<', or '//'.
  /// Emits the text token corresponding to the text processed.
  bool eatPlainText() {
    final position0 = position;
    while (!eof) {
      final cu = currentCodeUnit;
      if (cu == $lessThan || cu == $slash) {
        position += 1;
        if (currentCodeUnit == cu) {
          position -= 1;
          break;
        }
      } else if (cu == $carriageReturn ||
          cu == $lineFeed ||
          cu == $hash ||
          cu == $backslash ||
          cu == $leftBrace) {
        break;
      }
      position += 1;
    }
    if (position > position0) {
      pushToken(Token.text(text.substring(position0, position)), position0);
      return true;
    }
    return false;
  }

  /// Consumes a plain id within an expression, which is then emitted as either
  /// one of the [keywords] tokens, or as plain [Token.id].
  bool eatExpressionId() {
    final position0 = position;
    if (eatId()) {
      final name = tokens.last.content;
      final keywordToken = keywords[name];
      if (keywordToken != null) {
        popToken();
        pushToken(keywordToken, position0);
      }
      return true;
    }
    return false;
  }

  /// Consumes a variable within an expression. A variable is just a '$' sign
  /// followed by an id. Emits a [Token.variable].
  bool eatExpressionVariable() {
    final position0 = position;
    if (eat($dollar)) {
      if (eatId()) {
        final token = popToken();
        pushToken(Token.variable(r'$' + token.content), position0);
        return true;
      }
      position--;
      error('invalid variable name');
    }
    return false;
  }

  /// Consumes a number in the form of `DIGITS (. DIGITS)?`, and emits a
  /// corresponding token.
  bool eatNumber() {
    final position0 = position;
    if (eatDigits()) {
      eat($dot) && eatDigits();
      pushToken(Token.number(text.substring(position0, position)), position0);
      return true;
    }
    return false;
  }

  /// Helper for [_eatNumber]: consumes a simple run of digits.
  bool eatDigits() {
    var found = false;
    while (!eof) {
      final cu = currentCodeUnit;
      if (cu >= $digit0 && cu <= $digit9) {
        found = true;
        position++;
      } else {
        break;
      }
    }
    return found;
  }

  /// Consumes one of the operators defined in the [keywords] map, and emits
  /// a corresponding token.
  bool eatOperator() {
    if (position + 1 < text.length) {
      final op2 = text.substring(position, position + 2);
      final keyword = keywords[op2];
      if (keyword != null) {
        pushToken(keyword, position);
        position += 2;
        return true;
      }
    }
    if (position < text.length) {
      final op1 = text.substring(position, position + 1);
      final keyword = keywords[op1];
      if (keyword != null) {
        pushToken(keyword, position);
        position += 1;
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
    final position0 = position;
    final quote = currentCodeUnit;
    if (quote == $doubleQuote || quote == $singleQuote) {
      final buffer = StringBuffer();
      position += 1;
      while (!eof) {
        final cu = currentCodeUnit;
        if (cu == quote) {
          position += 1;
          pushToken(Token.string(buffer.toString()), position0);
          return true;
        } else if (cu == $carriageReturn || cu == $lineFeed) {
          error('unexpected end of line while parsing a string');
          break;
        } else if (cu == $backslash) {
          position += 1;
          final cu2 = currentCodeUnit;
          position += 1;
          if (cu2 == $singleQuote || cu2 == $doubleQuote || cu2 == $backslash) {
            buffer.writeCharCode(cu2);
          } else if (cu2 == $lowercaseN) {
            buffer.writeCharCode($lineFeed);
          } else {
            break;
          }
        } else {
          buffer.writeCharCode(cu);
          position += 1;
        }
      }
    }
    position = position0;
    return false;
  }

  /// Consumes a name of the command (ID) and emits it as a token. After that,
  /// goes either into expression mode if the command expects arguments, or
  /// remains in the command mode otherwise. User-defined commands are assumed
  /// to always allow expressions.
  bool eatCommandName() {
    final position0 = position;
    if (eatId()) {
      final token = popToken();
      final name = token.content;
      final commandToken = commandTokens[name];
      if (commandToken != null) {
        pushToken(commandToken, position0);
        if (commandToken == Token.commandIf ||
            commandToken == Token.commandElseif ||
            commandToken == Token.commandWait ||
            commandToken == Token.commandSet ||
            commandToken == Token.commandDeclare) {
          pushToken(Token.startExpression, position0);
          pushMode(modeExpression);
        } else if (commandToken == Token.commandJump) {
          eatWhitespace();
          eatId() ||
              eatExpressionStart() ||
              error('an ID or an expression expected');
        } else if (commandToken == Token.commandSet) {}
      } else {
        pushToken(Token.command(name), position0);
        pushToken(Token.startExpression, position0);
        pushMode(modeExpression);
      }
      return true;
    }
    return false;
  }

  /// Check whether a command terminated prematurely.
  bool eatCommandNewline() {
    final cu = currentCodeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      error('missing command close token ">>"');
    }
    return false;
  }

  /// Consumes a simple hash-tag sequence, consisting of '#' followed by any
  /// number of non-control characters.
  bool eatHashtag() {
    final position0 = position;
    if (eat($hash)) {
      while (!eof) {
        final cu = currentCodeUnit;
        if (cu == $slash && eat($slash) && eat($slash)) {
          position -= 2;
          break;
        }
        if (cu == $lineFeed ||
            cu == $carriageReturn ||
            cu == $space ||
            cu == $tab ||
            cu == $hash ||
            cu == $dollar ||
            cu == $lessThan) {
          break;
        }
        position += 1;
      }
      if (position > position0 + 1) {
        final tag = text.substring(position0, position);
        pushToken(Token.hashtag(tag), position0);
        return true;
      }
    }
    position = position0;
    return false;
  }

  static const Map<String, Token> keywords = {
    'true': Token.constTrue,
    'false': Token.constFalse,
    'string': Token.typeString,
    'number': Token.typeNumber,
    'bool': Token.typeBool,
    'as': Token.asType,
    'to': Token.operatorAssign,
    '=': Token.operatorAssign,
    'is': Token.operatorEqual,
    'eq': Token.operatorEqual,
    '==': Token.operatorEqual,
    'neq': Token.operatorNotEqual,
    'ne': Token.operatorNotEqual,
    '!=': Token.operatorNotEqual,
    'le': Token.operatorLessOrEqual,
    'lte': Token.operatorLessOrEqual,
    '<=': Token.operatorLessOrEqual,
    'ge': Token.operatorGreaterOrEqual,
    'gte': Token.operatorGreaterOrEqual,
    '>=': Token.operatorGreaterOrEqual,
    'lt': Token.operatorLessThan,
    '<': Token.operatorLessThan,
    'gt': Token.operatorGreaterThan,
    '>': Token.operatorGreaterThan,
    'and': Token.operatorAnd,
    '&&': Token.operatorAnd,
    'or': Token.operatorOr,
    '||': Token.operatorOr,
    'xor': Token.operatorXor,
    '^': Token.operatorXor,
    'not': Token.operatorNot,
    '!': Token.operatorNot,
    '+': Token.operatorPlus,
    '-': Token.operatorMinus,
    '*': Token.operatorMultiply,
    '/': Token.operatorDivide,
    '%': Token.operatorModulo,
    '+=': Token.operatorPlusAssign,
    '-=': Token.operatorMinusAssign,
    '*=': Token.operatorMultiplyAssign,
    '/=': Token.operatorDivideAssign,
    '%=': Token.operatorModuloAssign,
    ',': Token.comma,
    '(': Token.startParenthesis,
    ')': Token.endParenthesis,
  };
  static const Map<String, Token> commandTokens = {
    'declare': Token.commandDeclare,
    'else': Token.commandElse,
    'elseif': Token.commandElseif,
    'endif': Token.commandEndif,
    'if': Token.commandIf,
    'jump': Token.commandJump,
    'set': Token.commandSet,
    'stop': Token.commandStop,
    'wait': Token.commandWait,
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
    final locationDescription = _errorMessageAtPosition(position);
    throw SyntaxError('$message\n$locationDescription\n');
  }

  String _errorMessageAtPosition(int position) {
    final lineEnd = _findLineEnd(position);
    final lineStart = _findLineStart(position);
    String lineFragment, markerIndent;
    if (lineEnd - lineStart <= 74) {
      lineFragment = text.substring(lineStart, lineEnd);
      markerIndent = ' ' * (position - lineStart);
    } else if (position - lineStart <= 50) {
      lineFragment = '${text.substring(lineStart, lineStart + 74)}...';
      markerIndent = ' ' * (position - lineStart);
    } else if (lineEnd - position <= 40) {
      lineFragment = '...${text.substring(lineEnd - 77, lineEnd)}';
      markerIndent = ' ' * (position - lineEnd + 80);
    } else {
      lineFragment = '...${text.substring(position - 36, position + 35)}...';
      markerIndent = ' ' * 39;
    }
    final line = this.position <= lineEnd ? lineNumber : lineNumber - 1;
    return '>  at line $line column ${position - lineStart + 1}:\n'
        '>  $lineFragment\n'
        '>  $markerIndent^';
  }

  int _findLineStart(int position) {
    var i = position - 1;
    while (i >= 0) {
      final cu = text.codeUnitAt(i);
      if (cu == $lineFeed || cu == $carriageReturn) {
        break;
      }
      i -= 1;
    }
    return i + 1;
  }

  /// Returns the position where the current (starting at [position]) line ends,
  /// without altering the parsing location.
  int _findLineEnd(int position) {
    var i = position;
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
