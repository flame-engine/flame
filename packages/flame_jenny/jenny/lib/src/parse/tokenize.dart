import 'package:jenny/src/errors.dart';
import 'package:jenny/src/parse/ascii.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:meta/meta.dart';

/// Parses the [input] into a stream of [Token]s, according to the Yarn syntax.
///
/// If [addErrorTokenAtIndex] argument is given, then it would cause the lexer
/// to insert a [Token.error] at the specified index in the stream. This token
/// will be formatted to contain the line and column number at that parsing
/// position, as well as the line sample. This functionality can be used when
/// we need to throw an error from the parsing stage.
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
    if (tokens.length == addErrorTokenAtIndex) {
      tokens.add(Token.error(_errorMessageAtPosition(position)));
    }
    return tokens;
  }

  /// Has current parse position reached the end of file?
  bool get eof => position == text.length;

  /// Returns the integer code unit at the current parse position, or -1 if we
  /// reached the end of input.
  int get currentCodeUnit =>
      position < text.length ? text.codeUnitAt(position) : -1;

  int get nextCodeUnit =>
      position < text.length - 1 ? text.codeUnitAt(position + 1) : -1;

  /// Pushes a new mode into the mode stack and returns `true`.
  bool pushMode(_ModeFn mode) {
    modeStack.add(mode);
    return true;
  }

  /// Pops the last mode from the stack, checks that it was [mode], and returns
  /// `true`.
  bool popMode(_ModeFn mode) {
    final removed = modeStack.removeLast();
    assert(removed == mode, 'Expected $mode but found $removed');
    return true;
  }

  /// Pushes a new [token] into the output and returns `true`.
  ///
  /// The [tokenStartPosition] indicates the position in the stream where the
  /// current token starts.
  bool pushToken(Token token, int tokenStartPosition) {
    if (tokens.length == addErrorTokenAtIndex) {
      tokens.add(Token.error(_errorMessageAtPosition(tokenStartPosition)));
    }
    tokens.add(token);
    return true;
  }

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

  /// Initial mode, outside of the nodes. The following syntaxes are allowed
  /// here: file-level hashtags, and commands. The mode ends when it encounters
  /// a start-of-header sequence '---', or if there is any content other than
  /// hashtags and commands.
  ///
  /// Note that this mode is never popped off the mode stack.
  bool modeMain() {
    return eatEmptyLine() ||
        eatComment() ||
        eatHashtagLine() ||
        (eatCommandStart() && pushMode(modeCommand)) ||
        (eatHeaderStart() && pushMode(modeNodeHeader)) ||
        (pushToken(Token.startHeader, position) && pushMode(modeNodeHeader));
  }

  /// Parsing node header, this mode is only active at a start of a line, and
  /// after parsing an initial token, it pushes [modeNodeHeaderLine] which
  /// remains active until the end of the line.
  ///
  /// The mode switches to [modeNodeBody] upon encountering the '---' sequence.
  bool modeNodeHeader() {
    return eatEmptyLine() ||
        eatComment() ||
        (eatId() && pushMode(modeNodeHeaderLine)) ||
        (eatWhitespace() && error('unexpected indentation')) ||
        (eatHeaderEnd() &&
            popMode(modeNodeHeader) &&
            pushToken(Token.startBody, position) &&
            pushMode(modeNodeBody)) ||
        error('expected end-of-header marker "---"');
  }

  /// Mode which activates at each line of [modeNodeHeader] after an ID at the
  /// start of the line is consumed, and remains active until the end of the
  /// line.
  bool modeNodeHeaderLine() {
    return eatWhitespace() ||
        (eat($colon) && pushToken(Token.colon, position - 1)) ||
        (eatHeaderRestOfLine() && popMode(modeNodeHeaderLine));
  }

  /// The top-level mode for parsing the body of a Node. This mode is active at
  /// the start of each line only, and will turn into [modeNodeBodyLine] after
  /// taking care of whitespace.
  bool modeNodeBody() {
    return eatEmptyLine() ||
        eatComment() ||
        (eatBodyEnd() && popMode(modeNodeBody)) ||
        (eatIndent() && pushMode(modeNodeBodyLine));
  }

  /// The mode for parsing regular lines of a node body. This mode is active at
  /// the beginning of the line only (after the indent), where it attempts to
  /// disambiguate between what kind of line it is and then switches to either
  /// [modeCommand] or [modeText].
  bool modeNodeBodyLine() {
    return eatWhitespace() ||
        eatArrow() ||
        (eatCommandStart() && pushMode(modeCommand)) ||
        (eatCharacterName() && pushMode(modeText)) ||
        (eatNewline() && popMode(modeNodeBodyLine)) ||
        pushMode(modeText);
  }

  /// The mode of a regular text line within the node body. This mode will
  /// consume the input until the end of the line, and switch to [modeTextEnd].
  bool modeText() {
    return eatTextEscapeSequence() ||
        eatPlainText() ||
        eatCommandEndAsText() ||
        (eatExpressionStart() && pushMode(modeTextExpression)) ||
        (eatMarkupStart() && pushMode(modeMarkup)) ||
        (popMode(modeText) && pushMode(modeTextEnd));
  }

  /// Mode at the end of a line, allows hashtags and comments.
  bool modeTextEnd() {
    return eatWhitespace() ||
        eatComment() ||
        eatHashtag() ||
        (eatCommandStart() && pushMode(modeCommand)) ||
        (eatNewline() && popMode(modeTextEnd) && popMode(modeNodeBodyLine));
  }

  /// The command mode starts with a '<<', then consumes the command name, and
  /// after that either switches to a different mode depending on which command
  /// was encountered.
  bool modeCommand() {
    return eatWhitespace() ||
        (eatCommandName() &&
            (false || // subsequent mode will depend on the command type
                (simpleCommands.contains(tokens.last)) ||
                (bareExpressionCommands.contains(tokens.last) &&
                    pushToken(Token.startExpression, position) &&
                    pushMode(modeCommandExpression)) ||
                (tokens.last == Token.commandJump &&
                    (eatId() ||
                        (eatExpressionStart() &&
                            pushMode(modeTextExpression)) ||
                        error('an ID or an expression expected'))) ||
                (tokens.last.isCommand && // user-defined commands
                    pushMode(modeCommandText)))) ||
        (eatCommandEnd() && popMode(modeCommand)) ||
        checkNewlineInCommand();
  }

  /// Mode for the content of a user-defined command. It is almost the same as
  /// [modeText], except that it ends at '>>'.
  bool modeCommandText() {
    return (eatExpressionStart() && pushMode(modeTextExpression)) ||
        (eatCommandEnd() && popMode(modeCommandText) && popMode(modeCommand)) ||
        eatTextEscapeSequence() ||
        eatPlainText();
  }

  /// An expression within a [modeText] or [modeCommandText]. The expression
  /// is surrounded with curly braces `{ }`.
  bool modeTextExpression() {
    return eatWhitespace() ||
        eatExpressionId() ||
        eatExpressionVariable() ||
        eatNumber() ||
        eatString() ||
        eatOperator() ||
        (eatExpressionEnd() && popMode(modeTextExpression));
  }

  bool modeMarkupExpression() {
    return eatWhitespace() ||
        eatExpressionId() ||
        eatExpressionVariable() ||
        eatNumber() ||
        eatString() ||
        eatOperator() ||
        popMode(modeMarkupExpression);
  }

  /// An expression within a [modeCommand]. Such expression starts immediately
  /// after the command name and ends at `>>`.
  bool modeCommandExpression() {
    return eatWhitespace() ||
        (eatExpressionCommandEnd() &&
            popMode(modeCommandExpression) &&
            popMode(modeCommand)) ||
        eatExpressionId() ||
        eatExpressionVariable() ||
        eatNumber() ||
        eatString() ||
        eatOperator();
  }

  bool modeMarkup() {
    return checkNewlineInMarkup() ||
        eatMarkupCloseTag() ||
        (eatMarkupEnd() && popMode(modeMarkup)) ||
        pushMode(modeMarkupExpression);
  }

  //----------------------------------------------------------------------------
  // All `eat*()` methods will attempt to consume a specific type of syntax at
  // the current parsing location. If successful, the functions will:
  //   - advance the parsing position [position];
  //   - emit 0 or more tokens into the [tokens] stream;
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

  /// Consumes an empty line, i.e. a line consisting of whitespace only. Emits
  /// a newline token.
  bool eatEmptyLine() {
    final position0 = position;
    eatWhitespace();
    if (eof) {
      return true;
    }
    if (eatNewline()) {
      return true;
    } else {
      position = position0;
      return false;
    }
  }

  /// Consumes a comment line: `\s*//.*` up to but not including the newline,
  /// emitting no tokens.
  bool eatComment() {
    final position0 = position;
    eatWhitespace();
    if (eat($slash) && eat($slash)) {
      while (!eof) {
        final cu = currentCodeUnit;
        if (cu == $carriageReturn || cu == $lineFeed) {
          return true;
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
      lineNumber += 1;
      lineStart = position;
      pushToken(Token.newline, position0);
      return true;
    }
    return false;
  }

  /// Consumes a hashtag '#' followed by all characters until the end of the
  /// line. This is used for file-level tags. This rule is only used in
  /// [modeMain].
  bool eatHashtagLine() {
    final position0 = position;
    if (eat($hash)) {
      eatWhitespace();
      while (!eof) {
        final cu = currentCodeUnit;
        if (cu == $carriageReturn || cu == $lineFeed) {
          break;
        }
        position += 1;
      }
      pushToken(
        Token.hashtag(text.substring(position0, position)),
        position0,
      );
      if (!eatNewline()) {
        pushToken(Token.newline, position);
      }
      return true;
    }
    return false;
  }

  /// Consumes a start-of-header token (3 or more '-') followed by a newline.
  /// Note that the same character sequence encountered within the header body
  /// would mean the end of header section.
  bool eatHeaderStart() {
    final position0 = position;
    var numMinuses = 0;
    while (eat($minus)) {
      numMinuses++;
    }
    if (numMinuses >= 3 && eatNewline()) {
      popToken(Token.newline);
      pushToken(Token.startHeader, position0);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes an end-of-header token '---' followed by a newline, and emits a
  /// corresponding token.
  bool eatHeaderEnd() {
    final position0 = position;
    var numMinuses = 0;
    while (eat($minus)) {
      numMinuses++;
    }
    if (numMinuses >= 3 && eatNewline()) {
      popToken(Token.newline);
      pushToken(Token.endHeader, position0);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes+emits an end-of-body token '===' followed by a newline.
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
      if (cu == $carriageReturn ||
          cu == $lineFeed ||
          (cu == $slash && nextCodeUnit == $slash)) {
        break;
      }
    }
    pushToken(Token.text(text.substring(position0, position)), position0);
    eatComment();
    eatNewline();
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
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes+emits a command-start token '<<'.
  bool eatCommandStart() {
    final position0 = position;
    if (eat($lessThan) && eat($lessThan)) {
      pushToken(Token.startCommand, position0);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes+emits the end-of-command token '>>', and pops the [modeCommand].
  bool eatCommandEnd() {
    final position0 = position;
    if (eat($greaterThan) && eat($greaterThan)) {
      pushToken(Token.endCommand, position0);
      return true;
    }
    position = position0;
    return false;
  }

  /// Consumes a Unicode ID at the start of the line, followed by a ':', then
  /// emits a [Token.person] and a [Token.colon], and also switches into the
  /// [modeText].
  ///
  /// Note: we have to detect both the character name and the subsequent
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
        return true;
      }
    }
    position = position0;
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
            cu == $rightBrace ||
            cu == $leftBracket ||
            cu == $rightBracket) {
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

  /// Consumes '[' character.
  bool eatMarkupStart() {
    return eat($leftBracket) && pushToken(Token.startMarkupTag, position - 1);
  }

  /// Consumes '/' character inside a markup tag.
  bool eatMarkupCloseTag() {
    return eat($slash) && pushToken(Token.closeMarkupTag, position - 1);
  }

  /// Consumes ']' character. If previous character was '/' and it was parsed
  /// as an `operatorDivide` token, then replace that token with
  /// [Token.closeMarkupTag].
  bool eatMarkupEnd() {
    if (eat($rightBracket)) {
      final previousCodeUnit = text.codeUnitAt(position - 2);
      if (previousCodeUnit == $slash && tokens.last == Token.operatorDivide) {
        popToken(Token.operatorDivide);
        pushToken(Token.closeMarkupTag, position - 2);
      }
      if (tokens.last == Token.closeMarkupTag) {
        // Self-closing markup tag such as `[img/]`: consume a single whitespace
        // character after such tag (if present).
        eat($space);
      }
      pushToken(Token.endMarkupTag, position - 1);
      return true;
    }
    return false;
  }

  /// Consumes '{' token.
  bool eatExpressionStart() {
    return eat($leftBrace) && pushToken(Token.startExpression, position - 1);
  }

  /// Consumes '}' token.
  bool eatExpressionEnd() {
    return eat($rightBrace) && pushToken(Token.endExpression, position - 1);
  }

  /// Consumes '>>' while in the expression mode, and leaves both the expression
  /// mode and the [modeCommand].
  /// This rule is only allowed within an expression within a command mode.
  bool eatExpressionCommandEnd() {
    final position0 = position;
    if (eat($greaterThan) && eat($greaterThan)) {
      pushToken(Token.endExpression, position0);
      pushToken(Token.endCommand, position0);
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
    var positionBeforeWhitespace = position;
    while (!eof) {
      final cu = currentCodeUnit;
      // Stop when seeing (\n|\r|#|//|<<) and discard any preceding whitespace
      if ((cu == $slash && nextCodeUnit == $slash) ||
          (cu == $lessThan && nextCodeUnit == $lessThan) ||
          cu == $hash ||
          cu == $carriageReturn ||
          cu == $lineFeed) {
        position = positionBeforeWhitespace;
        break;
      }
      // Stop when seeing (>>|\\|{|[) and keep the whitespace
      else if ((cu == $greaterThan && nextCodeUnit == $greaterThan) ||
          cu == $backslash ||
          cu == $leftBrace ||
          cu == $leftBracket) {
        break;
      }
      // Error when seeing unescaped (]|})
      else if (cu == $rightBrace || cu == $rightBracket) {
        error('special character needs to be escaped');
      }
      position += 1;
      if (!(cu == $space || cu == $tab)) {
        positionBeforeWhitespace = position;
      }
    }
    if (position > position0) {
      pushToken(Token.text(text.substring(position0, position)), position0);
      return true;
    }
    return false;
  }

  bool eatCommandEndAsText() {
    if (currentCodeUnit == $greaterThan && nextCodeUnit == $greaterThan) {
      pushToken(const Token.text('>>'), position);
      position += 2;
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

  /// Consumes a name of the command (ID) and emits it as a token.
  bool eatCommandName() {
    final position0 = position;
    if (eatId()) {
      eatWhitespace();
      final token = popToken();
      final commandToken = commandTokens[token.content];
      if (commandToken != null) {
        pushToken(commandToken, position0);
      } else {
        pushToken(Token.command(token.content), position0);
      }
      return true;
    }
    return false;
  }

  /// Check whether a command terminated prematurely.
  bool checkNewlineInCommand() {
    final cu = currentCodeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      error('missing command close token ">>"');
    }
    return false;
  }

  /// Check whether a command terminated prematurely.
  bool checkNewlineInMarkup() {
    final cu = currentCodeUnit;
    if (cu == $carriageReturn || cu == $lineFeed) {
      error('missing markup tag close token "]"');
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
        if ((cu == $slash && nextCodeUnit == $slash) ||
            cu == $lineFeed ||
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
    'String': Token.typeString,
    'Number': Token.typeNumber,
    'Bool': Token.typeBool,
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
    'local': Token.commandLocal,
    'set': Token.commandSet,
    'stop': Token.commandStop,
    'wait': Token.commandWait,
  };

  /// Built-in commands that have no arguments.
  static final Set<Token> simpleCommands = {
    Token.commandElse,
    Token.commandEndif,
    Token.commandStop,
  };

  /// Built-in commands that are followed by an expression (without `{}`).
  static final Set<Token> bareExpressionCommands = {
    Token.commandDeclare,
    Token.commandElseif,
    Token.commandIf,
    Token.commandLocal,
    Token.commandSet,
    Token.commandWait,
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
