import 'package:meta/meta.dart';

/// [Token] is a unit of output during the lexing stage.
@internal
@immutable
class Token {
  const Token._(this.type, [this._content]);

  const Token.command(String text) : this._(TokenType.command, text);
  const Token.id(String text) : this._(TokenType.id, text);
  const Token.number(String text) : this._(TokenType.number, text);
  const Token.speaker(String text) : this._(TokenType.speaker, text);
  const Token.string(String text) : this._(TokenType.string, text);
  const Token.text(String text) : this._(TokenType.text, text);
  const Token.variable(String text) : this._(TokenType.variable, text);

  static const arrow = Token._(TokenType.arrow);
  static const as = Token._(TokenType.as);
  static const colon = Token._(TokenType.colon);
  static const comma = Token._(TokenType.comma);
  static const commandElse = Token._(TokenType.commandElse);
  static const commandElseif = Token._(TokenType.commandElseif);
  static const commandEndif = Token._(TokenType.commandEndif);
  static const commandIf = Token._(TokenType.commandIf);
  static const commandJump = Token._(TokenType.commandJump);
  static const commandSet = Token._(TokenType.commandSet);
  static const commandStop = Token._(TokenType.commandStop);
  static const commandWait = Token._(TokenType.commandWait);
  static const constFalse = Token._(TokenType.constFalse);
  static const constTrue = Token._(TokenType.constTrue);
  static const endBody = Token._(TokenType.endBody);
  static const endCommand = Token._(TokenType.endCommand);
  static const endExpression = Token._(TokenType.endExpression);
  static const endIndent = Token._(TokenType.endIndent);
  static const endParen = Token._(TokenType.endParen);
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
  static const startBody = Token._(TokenType.startBody);
  static const startCommand = Token._(TokenType.startCommand);
  static const startExpression = Token._(TokenType.startExpression);
  static const startIndent = Token._(TokenType.startIndent);
  static const startParen = Token._(TokenType.startParen);
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
  command,
  id,
  number,
  speaker,
  string,
  text,
  variable,

  arrow, //            '->'
  as, //               'as'
  colon, //            ':'
  comma, //            ','
  commandElse, //      'else'
  commandElseif, //    'elseif'
  commandEndif, //     'endif'
  commandIf, //        'if'
  commandJump, //      'jump'
  commandSet, //       'set'
  commandStop, //      'stop'
  commandWait, //      'wait'
  constFalse, //       'false'
  constTrue, //        'true'
  endBody, //          '==='
  endCommand, //       '>>'
  endExpression, //    '}'
  endIndent, //        RegExp(r'^\s*')
  endParen, //         ')'
  newline, //          '\r' | '\n' | '\r\n'
  opAnd, //            'and' | '&&'
  opAssign, //         'to' | '='
  opDivide, //         '/'
  opDivideAssign, //   '/='
  opEq, //             'is' | 'eq' | '=='
  opGe, //             'ge' | 'gte' | '>='
  opGt, //             'gt' | '>'
  opLe, //             'le' | 'lte | '<='
  opLt, //             'lt' | '<'
  opMinus, //          '-'
  opMinusAssign, //    '-='
  opModulo, //         '%'
  opModuloAssign, //   '%='
  opMultiply, //       '*'
  opMultiplyAssign, // '*='
  opNe, //             'ne' | 'neq' | '!='
  opNot, //            'not' | '!'
  opOr, //             'or' | '||'
  opPlus, //           '+'
  opPlusAssign, //     '+='
  opXor, //            'xor' | '^'
  startBody, //        '---'
  startCommand, //     '<<'
  startExpression, //  '{'
  startIndent, //      RegExp(r'^\s*')
  startParen, //       '('
  typeBool, //         'bool'
  typeNumber, //       'number'
  typeString, //       'string'
}
