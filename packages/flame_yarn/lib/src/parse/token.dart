import 'package:meta/meta.dart';

/// [Token] is a unit of output during the lexing stage.
@internal
@immutable
class Token {
  const Token._(this.type, [this._content]);

  const Token.text(String text) : this._(TokenType.text, text);
  const Token.number(String text) : this._(TokenType.number, text);
  const Token.string(String text) : this._(TokenType.string, text);
  const Token.command(String text) : this._(TokenType.command, text);
  const Token.variable(String text) : this._(TokenType.variable, text);
  const Token.speaker(String text) : this._(TokenType.speaker, text);
  const Token.id(String text) : this._(TokenType.id, text);

  static const arrow = Token._(TokenType.arrow);
  static const as = Token._(TokenType.as);
  static const bodyEnd = Token._(TokenType.bodyEnd);
  static const comma = Token._(TokenType.comma);
  static const commandElse = Token._(TokenType.commandElse);
  static const commandElseif = Token._(TokenType.commandElseif);
  static const commandEnd = Token._(TokenType.commandEnd);
  static const commandEndif = Token._(TokenType.commandEndif);
  static const commandIf = Token._(TokenType.commandIf);
  static const commandJump = Token._(TokenType.commandJump);
  static const commandSet = Token._(TokenType.commandSet);
  static const commandStart = Token._(TokenType.commandStart);
  static const commandStop = Token._(TokenType.commandStop);
  static const commandWait = Token._(TokenType.commandWait);
  static const constFalse = Token._(TokenType.constFalse);
  static const constTrue = Token._(TokenType.constTrue);
  static const dedent = Token._(TokenType.dedent);
  static const expressionEnd = Token._(TokenType.expressionEnd);
  static const expressionStart = Token._(TokenType.expressionStart);
  static const headerEnd = Token._(TokenType.headerEnd);
  static const indent = Token._(TokenType.indent);
  static const newline = Token._(TokenType.newline);
  static const opAnd = Token._(TokenType.opAnd);
  static const opAssign = Token._(TokenType.opAssign);
  static const opDivide = Token._(TokenType.opDivide);
  static const opDivideAssign = Token._(TokenType.opDivideAssign);
  static const opEq = Token._(TokenType.opEq);
  static const opGe = Token._(TokenType.opGe);
  static const opGt = Token._(TokenType.opGt);
  static const opLe = Token._(TokenType.opLe);
  static const opLt = Token._(TokenType.opLt);
  static const opMinus = Token._(TokenType.opMinus);
  static const opMinusAssign = Token._(TokenType.opMinusAssign);
  static const opModulo = Token._(TokenType.opModulo);
  static const opModuloAssign = Token._(TokenType.opModuloAssign);
  static const opMultiply = Token._(TokenType.opMultiply);
  static const opMultiplyAssign = Token._(TokenType.opMultiplyAssign);
  static const opNe = Token._(TokenType.opNe);
  static const opNot = Token._(TokenType.opNot);
  static const opOr = Token._(TokenType.opOr);
  static const opPlus = Token._(TokenType.opPlus);
  static const opPlusAssign = Token._(TokenType.opPlusAssign);
  static const opXor = Token._(TokenType.opXor);
  static const parenEnd = Token._(TokenType.parenEnd);
  static const parenStart = Token._(TokenType.parenStart);
  static const typeBool = Token._(TokenType.typeBool);
  static const typeNumber = Token._(TokenType.typeNumber);
  static const typeString = Token._(TokenType.typeString);

  final TokenType type;
  final String? _content;

  /// The content can only be accessed for tokens of type "text", "number",
  /// "string", "command", "variable", "speaker", and "id".
  String get content => _content!;

  @override
  String toString() =>
      'Token.${type.name}${_content == null ? '' : "('$_content')"}';

  @override
  int get hashCode => Object.hash(type, _content);

  @override
  bool operator ==(Object other) =>
      other is Token && other.type == type && other._content == _content;
}

@internal
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
