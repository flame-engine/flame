import 'package:flame_yarn/src/parse/ascii.dart';

class Lexer {
  String text = '';
  int pos = 0;
  List<Token> tokens = [];
  final List<_ModeFn> _modeStack = [];
  final List<int> _indentStack = [];

  List<Token> tokenize(String text) {
    this.text = text;
    pos = 0;
    _indentStack.add(0);

    _pushMode(_nodeHeaderMode);
    while (!eof) {
      final parser = _modeStack.last;
      final ok = parser();
      if (!ok) {
        throw SyntaxError();
      }
    }
    _popMode(_nodeHeaderMode);
    if (_modeStack.isNotEmpty) {
      throw SyntaxError();
    }

    return tokens;
  }

  /// Is current parse position reached the end of file?
  bool get eof => pos == text.length;

  /// Returns the integer code unit at the current parse position, or -1 if the
  /// parse reached the end of input.
  int get codeUnit => eof ? -1 : text.codeUnitAt(pos);

  void _pushMode(_ModeFn mode) => _modeStack.add(mode);

  void _popMode(_ModeFn mode) {
    final removed = _modeStack.removeLast();
    assert(removed == mode);
  }


  bool _nodeHeaderMode() {
    return _eatEmptyLine() ||
        _eatCommentLine() ||
        _eatHeaderEnd() ||
        _eatId() ||
        _eatHeaderDelimiterAndRestOfLine();
  }

  bool _nodeBodyMode() {
    return _eatEmptyLine() ||
        _eatCommentLine() ||
        _eatBodyEnd() ||
        _eatIndent();
  }

  bool _nodeBodyLineMode() {
    return _eatArrow() ||
        _eatCommandStart() ||
        _eatCharacterName() ||
        _switchToTextMode();
  }

  bool _switchToTextMode() {
    _pushMode(_textMode);
    return true;
  }

  bool _textMode() {
    return _eatTextCommentOrNewline() ||
        _eatTextEscapeSequence() ||
        _eatExpressionStart() ||
        _eatPlainText();
  }

  bool _expressionMode() {
    return _eatWhitespace() ||
        _eatExpressionId() ||
        _eatExpressionVariable() ||
        _eatNumber() ||
        _eatString() ||
        _eatOperator() ||
        _eatExpressionEnd() ||
        _eatExpressionCommandEnd();
  }

  bool _commandMode() {
    return _eatWhitespace() ||
      _eatCommandName() ||
      _eatCommandEnd();
  }

  //----------------------------------------------------------------------------
  /// All `_eat*()` methods will attempt to consume a specific type of syntax at
  /// the current parsing location. If successful, the functions will:
  ///   - advance the parsing position [pos];
  ///   - emit 0 or 1 token into the [tokens] token stream;
  ///   - possibly pushes a new mode or pops the current mode;
  ///   - return `true`.
  /// Otherwise, the function will:
  ///   - leave [pos] unmodified;
  ///   - return `false`.
  //----------------------------------------------------------------------------

  /// Consumes a single character with code unit [cu].
  bool _eat(int cu) {
    if (codeUnit == cu) {
      pos += 1;
      return true;
    }
    return false;
  }

  /// Consumes an empty line, i.e. a line consisting of whitespace only. Does
  /// not emit any tokens.
  bool _eatEmptyLine() {
    final pos0 = pos;
    _eatWhitespace();
    if (_eatNewline()) {
      return true;
    } else {
      pos = pos0;
      return false;
    }
  }

  /// Consumes a comment line: `\s*//.*` up to and including the newline,
  /// without emitting any tokens.
  bool _eatCommentLine() {
    final pos0 = pos;
    _eatWhitespace();
    if (_eat($slash) && _eat($slash)) {
      while (!eof) {
        final cu = codeUnit;
        if (cu == $cr || cu == $lf) {
          _eatNewline();
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
  bool _eatWhitespace() {
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
  /// without emitting any tokens.
  bool _eatNewline() {
    final cu = codeUnit;
    if (cu == $cr || cu == $lf) {
      pos += 1;
      if (cu == $cr && codeUnit == $lf) {
        pos += 1;
      }
      return true;
    }
    return false;
  }

  /// Consumes an end-of-header token '---' followed by a newline, emits a
  /// token, and switches to the [_nodeBodyMode].
  bool _eatHeaderEnd() {
    final pos0 = pos;
    if (_eat($minus) && _eat($minus) && _eat($minus) && _eatNewline()) {
      tokens.add(const Token(TokenType.headerEnd));
      _pushMode(_nodeBodyMode);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes an end-of-body token '===' followed by a newline, emits a token,
  /// and pops the current mode.
  bool _eatBodyEnd() {
    final pos0 = pos;
    if (_eat($equals) && _eat($equals) && _eat($equals) && _eatNewline()) {
      tokens.add(const Token(TokenType.bodyEnd));
      _popMode(_nodeBodyMode);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes a word that looks like an identifier, and emits an .id token.
  bool _eatId() {
    final pos0 = pos;
    var cu = codeUnit;
    if ((cu >= $lowercaseA && cu <= $lowercaseZ) ||
        (cu >= $uppercaseA && cu <= $uppercaseZ)) {
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
      tokens.add(Token(TokenType.id, text.substring(pos0, pos)));
      return true;
    }
    return false;
  }

  /// Consumes a ':' within the header, and then the rest of the line which is
  /// emitted as a plain text token.
  bool _eatHeaderDelimiterAndRestOfLine() {
    final pos0 = pos;
    _eatWhitespace();
    if (_eat($colon)) {
      _eatWhitespace();
      final pos0 = pos;
      var pos1 = pos;
      while (!eof) {
        pos1 = pos;
        if (_eatNewline()) {
          break;
        }
        pos += 1;
      }
      tokens.add(Token(TokenType.text, text.substring(pos0, pos1)));
      return true;
    } else {
      pos = pos0;
      return false;
    }
  }

  /// Consumes whitespace at the start of the line (if any) and emits indent/
  /// dedent tokens according to the indent stack. After that switches to the
  /// [_nodeBodyLineMode]. Always returns true (even if a line had 0 spaces).
  bool _eatIndent() {
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
    if (lineIndent > _indentStack.last) {
      _indentStack.add(lineIndent);
      tokens.add(const Token(TokenType.indent));
    }
    while (lineIndent < _indentStack.last) {
      _indentStack.removeLast();
      tokens.add(const Token(TokenType.dedent));
    }
    if (lineIndent > _indentStack.last) {
      throw SyntaxError('Inconsistent indentation');
    }
    _pushMode(_nodeBodyLineMode);
    return true;
  }

  /// Consumes an arrow token '->' and emits it.
  bool _eatArrow() {
    final pos0 = pos;
    if (_eat($minus) && _eat($gt)) {
      tokens.add(const Token(TokenType.arrow));
      _eatWhitespace();
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes+emits a command start token '<<', and switches to the
  /// [_commandMode].
  bool _eatCommandStart() {
    final pos0 = pos;
    if (_eat($lt) && _eat($lt)) {
      tokens.add(const Token(TokenType.commandStart));
      _eatWhitespace();
      _pushMode(_commandMode);
      return true;
    }
    pos = pos0;
    return false;
  }

  bool _eatCommandEnd() {
    final pos0 = pos;
    if (_eat($gt) && _eat($gt)) {
      tokens.add(const Token(TokenType.commandEnd));
      _eatWhitespace();
      _popMode(_commandMode);
      return true;
    }
    pos = pos0;
    return false;
  }

  /// Consumes an ID at the start of the line, followed by a ':', then emits a
  /// .speaker token.
  bool _eatCharacterName() {
    final numTokens = tokens.length;
    final pos0 = pos;
    if (_eatId()) {
      final idToken = tokens.removeLast();
      assert(tokens.length == numTokens && idToken.type == TokenType.id);
      _eatWhitespace();
      if (_eat($colon)) {
        _eatWhitespace();
        tokens.add(Token(TokenType.speaker, idToken.content));
        return true;
      }
    }
    pos = pos0;
    return false;
  }

  /// Consumes a comment at the end of line or a newline while in the text mode,
  /// and pops the current mode so that the next line will start again at
  /// [_nodeBodyMode].
  bool _eatTextCommentOrNewline() {
    if (_eatNewline() || _eatCommentLine()) {
      _popMode(_textMode);
      _popMode(_nodeBodyLineMode);
      assert(_modeStack.last == _nodeBodyMode);
      return true;
    }
    return false;
  }

  bool _eatTextEscapeSequence() {
    if (_eat($backslash)) {
      if (_eatNewline()) {
        _eatWhitespace();
      } else {
        final cu = codeUnit;
        if (cu == $backslash || cu == $slash || cu == $lt || cu == $gt ||
            cu == $leftBrace || cu == $rightBrace || cu == $hash) {
          pos += 1;
          tokens.add(Token(TokenType.text, String.fromCharCode(cu)));
        } else if (cu == $lowercaseN) {
          pos += 1;
          tokens.add(const Token(TokenType.text, '\n'));
        }
        else {
          throw SyntaxError('Invalid escape sequence');
        }
      }
      return true;
    }
    return false;
  }

  /// Consumes '{' and enters the [_expressionMode].
  bool _eatExpressionStart() {
    if (_eat($leftBrace)) {
      tokens.add(const Token(TokenType.expressionStart));
      _pushMode(_expressionMode);
      return true;
    }
    return false;
  }

  /// Consumes '}' and leaves the [_expressionMode].
  bool _eatExpressionEnd() {
    if (_eat($rightBrace)) {
      tokens.add(const Token(TokenType.expressionEnd));
      _popMode(_expressionMode);
      return true;
    }
    return false;
  }

  /// Consumes '>>' while in the expression mode, and leaves both the expression
  /// mode and the [_commandMode].
  bool _eatExpressionCommandEnd() {
    final pos0 = pos;
    if (_eat($gt) && _eat($gt)) {
      tokens.add(const Token(TokenType.expressionEnd));
      tokens.add(const Token(TokenType.commandEnd));
      _eatWhitespace();
      _popMode(_expressionMode);
      _popMode(_commandMode);
      return true;
    }
    pos = pos0;
    return false;
  }

  bool _eatPlainText() {
    final pos0 = pos;
    final cu = codeUnit;
    if (cu == $lt || cu == $slash) {
      pos += 1;
      tokens.add(Token(TokenType.text, String.fromCharCode(cu)));
    } else {
      while (!eof) {
        final cu = codeUnit;
        if (cu == $cr || cu == $lf || cu == $hash || cu == $leftBrace ||
            cu == $slash || cu == $backslash || cu == $lt) {
          break;
        }
        pos += 1;
      }
      if (pos > pos0) {
        tokens.add(Token(TokenType.text, text.substring(pos0, pos)));
      }
    }
    return pos > pos0;
  }

  /// Consumes a plain id within an expression, which is then emitted as either
  /// one of the [_keywords] tokens, or as plain .id token.
  bool _eatExpressionId() {
    if (_eatId()) {
      final name = tokens.last.content;
      final keywordToken = _keywords[name];
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
  bool _eatExpressionVariable() {
    if (_eat($dollar)) {
      if (_eatId()) {
        final token = tokens.removeLast();
        tokens.add(Token(TokenType.variable, token.content));
        return true;
      }
      pos--;
    }
    return false;
  }

  /// Consumes a number in the form of `DIGITS (. DIGITS)?`, and emits a
  /// corresponding token.
  bool _eatNumber() {
    final pos0 = pos;
    if (_eatDigits()) {
      _eat($dot) && _eatDigits();
      tokens.add(Token(TokenType.number, text.substring(pos, pos0)));
      return true;
    }
    return false;
  }

  /// Helper for [_eatNumber]: consumes a simple run of digits.
  bool _eatDigits() {
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

  /// Consumes one of the operators defined in the [_keywords] map, and emits
  /// a corresponding token.
  bool _eatOperator() {
    if (pos + 1 < text.length) {
      final op2 = text.substring(pos, pos + 2);
      final keyword = _keywords[op2];
      if (keyword != null) {
        pos += 2;
        tokens.add(keyword);
        return true;
      }
    }
    if (pos < text.length) {
      final op1 = text.substring(pos, pos + 1);
      final keyword = _keywords[op1];
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
  bool _eatString() {
    final pos0 = pos;
    final quote = codeUnit;
    if (quote == $doubleQuote || quote == $singleQuote) {
      final buffer = StringBuffer();
      pos += 1;
      while (!eof) {
        final cu = codeUnit;
        if (cu == quote) {
          pos += 1;
          tokens.add(Token(TokenType.string, buffer.toString()));
          return true;
        } else if (cu == $cr || cu == $lf) {
          break;
        } else if (cu == $backslash) {
          pos += 1;
          final cu2 = codeUnit;
          pos += 1;
          if (cu2 == $singleQuote || cu2 == $doubleQuote || cu2 == $backslash) {
            buffer.writeCharCode(cu2);
          } else if (cu2 == $lowercaseN) {
            buffer.writeCharCode($lf);
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

  bool _eatCommandName() {
    if (_eatId()) {
      final token = tokens.removeLast();
      final name = token.content;
      if (_commandsWithArgs.containsKey(name)) {
        tokens.add(_commandsWithArgs[name]!);
        _pushMode(_expressionMode);
      } else if (_commandsWithoutArgs.containsKey(name)) {
        tokens.add(_commandsWithoutArgs[name]!);
      } else {
        tokens.add(Token(TokenType.command, name));
        _pushMode(_expressionMode);
      }
      return true;
    }
    return false;
  }

  static const Map<String, Token> _keywords = {
    'true': Token(TokenType.constTrue),
    'false': Token(TokenType.constFalse),
    'string': Token(TokenType.typeString),
    'number': Token(TokenType.typeNumber),
    'bool': Token(TokenType.typeBool),
    'as': Token(TokenType.as),
    'to': Token(TokenType.opAssign),
    '=': Token(TokenType.opAssign),
    'is': Token(TokenType.opEq),
    'eq': Token(TokenType.opEq),
    '==': Token(TokenType.opEq),
    'neq': Token(TokenType.opNe),
    'ne': Token(TokenType.opNe),
    '!=': Token(TokenType.opNe),
    'le': Token(TokenType.opLe),
    'lte': Token(TokenType.opLe),
    '<=': Token(TokenType.opLe),
    'ge': Token(TokenType.opGe),
    'gte': Token(TokenType.opGe),
    '>=': Token(TokenType.opGe),
    'lt': Token(TokenType.opLt),
    '<': Token(TokenType.opLt),
    'gt': Token(TokenType.opGt),
    '>': Token(TokenType.opGt),
    'and': Token(TokenType.opAnd),
    '&&': Token(TokenType.opAnd),
    'or': Token(TokenType.opOr),
    '||': Token(TokenType.opOr),
    'xor': Token(TokenType.opXor),
    '^': Token(TokenType.opXor),
    'not': Token(TokenType.opNot),
    '!': Token(TokenType.opNot),
    '+': Token(TokenType.opPlus),
    '-': Token(TokenType.opMinus),
    '*': Token(TokenType.opMultiply),
    '/': Token(TokenType.opDivide),
    '%': Token(TokenType.opModulo),
    '+=': Token(TokenType.opPlusAssign),
    '-=': Token(TokenType.opMinusAssign),
    '*=': Token(TokenType.opMultiplyAssign),
    '/=': Token(TokenType.opDivideAssign),
    '%=': Token(TokenType.opModuloAssign),
    ',': Token(TokenType.comma),
    '(': Token(TokenType.parenStart),
    ')': Token(TokenType.parenEnd),
  };
  static const Map<String, Token> _commandsWithArgs = {
    'if': Token(TokenType.commandIf),
    'elseif': Token(TokenType.commandElseif),
    'set': Token(TokenType.commandSet),
    'jump': Token(TokenType.commandJump),
    'wait': Token(TokenType.commandJump),
  };
  static const Map<String, Token> _commandsWithoutArgs = {
    'else': Token(TokenType.commandElse),
    'endif': Token(TokenType.commandEndif),
    'stop': Token(TokenType.commandEndif),
  };
}

typedef _ModeFn = bool Function();

class Token {
  const Token(this.type, [this.content]);
  final TokenType type;
  final String? content;
}

enum TokenType {
  text,
  number,
  string,
  indent,
  dedent,
  id,
  speaker,
  command,
  variable, //         '$' ID
  newline, //          '\r' | '\n' | '\r\n'
  headerEnd, //        '---'
  bodyEnd, //          '==='
  arrow, //            '->'
  commandStart, //     '<<'
  commandEnd, //       '>>'
  expressionStart, //  '{'
  expressionEnd, //    '}'
  parenStart, //       '('
  parenEnd, //         ')'
  comma, //            ','
  constTrue, //        'true'
  constFalse, //       'false'
  typeString, //       'string'
  typeNumber, //       'number'
  typeBool, //         'bool'
  as, //               'as'
  opAssign, //         'to' | '='
  opEq, //             'is' | 'eq' | '=='
  opNe, //             'ne' | 'neq' | '!='
  opLe, //             'le' | 'lte | '<='
  opGe, //             'ge' | 'gte' | '>='
  opLt, //             'lt' | '<'
  opGt, //             'gt' | '>'
  opAnd, //            'and' | '&&'
  opOr, //             'or' | '||'
  opXor, //            'xor' | '^'
  opNot, //            'not' | '!'
  opPlus, //           '+'
  opMinus, //          '-'
  opMultiply, //       '*'
  opDivide, //         '/'
  opModulo, //         '%'
  opPlusAssign, //     '+='
  opMinusAssign, //    '-='
  opMultiplyAssign, // '*='
  opDivideAssign, //   '/='
  opModuloAssign, //   '%='
  commandIf, //        'if'
  commandElseif, //    'elseif'
  commandElse, //      'else'
  commandEndif, //     'endif'
  commandSet, //       'set'
  commandJump, //      'jump'
  commandWait, //      'wait'
  commandStop, //      'stop'
}

class SyntaxError implements Exception {
  SyntaxError([this.message]);
  final String? message;
}
