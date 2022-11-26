import 'package:meta/meta.dart';

/// [Token] is a unit of output during the lexing stage.
@internal
@immutable
class Token {
  const Token._(this.type, [this._content]);

  const Token.command(String text) : this._(TokenType.command, text);
  const Token.hashtag(String text) : this._(TokenType.hashtag, text);
  const Token.id(String text) : this._(TokenType.id, text);
  const Token.number(String text) : this._(TokenType.number, text);
  const Token.person(String text) : this._(TokenType.person, text);
  const Token.string(String text) : this._(TokenType.string, text);
  const Token.text(String text) : this._(TokenType.text, text);
  const Token.variable(String text) : this._(TokenType.variable, text);
  const Token.error(String text) : this._(TokenType.error, text);

  static const arrow = Token._(TokenType.arrow);
  static const asType = Token._(TokenType.asType);
  static const closeMarkupTag = Token._(TokenType.closeMarkupTag);
  static const colon = Token._(TokenType.colon);
  static const comma = Token._(TokenType.comma);
  static const commandDeclare = Token._(TokenType.commandDeclare);
  static const commandElse = Token._(TokenType.commandElse);
  static const commandElseif = Token._(TokenType.commandElseif);
  static const commandEndif = Token._(TokenType.commandEndif);
  static const commandIf = Token._(TokenType.commandIf);
  static const commandJump = Token._(TokenType.commandJump);
  static const commandLocal = Token._(TokenType.commandLocal);
  static const commandSet = Token._(TokenType.commandSet);
  static const commandStop = Token._(TokenType.commandStop);
  static const commandWait = Token._(TokenType.commandWait);
  static const constFalse = Token._(TokenType.constFalse);
  static const constTrue = Token._(TokenType.constTrue);
  static const endBody = Token._(TokenType.endBody);
  static const endCommand = Token._(TokenType.endCommand);
  static const endExpression = Token._(TokenType.endExpression);
  static const endHeader = Token._(TokenType.endHeader);
  static const endIndent = Token._(TokenType.endIndent);
  static const endMarkupTag = Token._(TokenType.endMarkupTag);
  static const endParenthesis = Token._(TokenType.endParenthesis);
  static const eof = Token._(TokenType.eof);
  static const newline = Token._(TokenType.newline);
  static const operatorAnd = Token._(TokenType.operatorAnd);
  static const operatorAssign = Token._(TokenType.operatorAssign);
  static const operatorDivide = Token._(TokenType.operatorDivide);
  static const operatorDivideAssign = Token._(TokenType.operatorDivideAssign);
  static const operatorEqual = Token._(TokenType.operatorEqual);
  static const operatorGreaterOrEqual =
      Token._(TokenType.operatorGreaterOrEqual);
  static const operatorGreaterThan = Token._(TokenType.operatorGreaterThan);
  static const operatorLessOrEqual = Token._(TokenType.operatorLessOrEqual);
  static const operatorLessThan = Token._(TokenType.operatorLessThan);
  static const operatorMinus = Token._(TokenType.operatorMinus);
  static const operatorMinusAssign = Token._(TokenType.operatorMinusAssign);
  static const operatorModulo = Token._(TokenType.operatorModulo);
  static const operatorModuloAssign = Token._(TokenType.operatorModuloAssign);
  static const operatorMultiply = Token._(TokenType.operatorMultiply);
  static const operatorMultiplyAssign =
      Token._(TokenType.operatorMultiplyAssign);
  static const operatorNotEqual = Token._(TokenType.operatorNotEqual);
  static const operatorNot = Token._(TokenType.operatorNot);
  static const operatorOr = Token._(TokenType.operatorOr);
  static const operatorPlus = Token._(TokenType.operatorPlus);
  static const operatorPlusAssign = Token._(TokenType.operatorPlusAssign);
  static const operatorXor = Token._(TokenType.operatorXor);
  static const startBody = Token._(TokenType.startBody);
  static const startCommand = Token._(TokenType.startCommand);
  static const startExpression = Token._(TokenType.startExpression);
  static const startHeader = Token._(TokenType.startHeader);
  static const startIndent = Token._(TokenType.startIndent);
  static const startMarkupTag = Token._(TokenType.startMarkupTag);
  static const startParenthesis = Token._(TokenType.startParenthesis);
  static const typeBool = Token._(TokenType.typeBool);
  static const typeNumber = Token._(TokenType.typeNumber);
  static const typeString = Token._(TokenType.typeString);

  final TokenType type;
  final String? _content;

  bool get isCommand => type == TokenType.command;
  bool get isHashtag => type == TokenType.hashtag;
  bool get isId => type == TokenType.id;
  bool get isNumber => type == TokenType.number;
  bool get isPerson => type == TokenType.person;
  bool get isString => type == TokenType.string;
  bool get isText => type == TokenType.text;
  bool get isVariable => type == TokenType.variable;

  /// The content can only be accessed for tokens of type "text", "number",
  /// "string", "command", "variable", "person", and "id".
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
  hashtag,
  id,
  number,
  person,
  string,
  text,
  variable,

  arrow, //                  '->'
  asType, //                 'as'
  closeMarkupTag, //         '/'  (e.g. in "[br/]")
  colon, //                  ':'
  comma, //                  ','
  commandDeclare, //         'declare'
  commandElse, //            'else'
  commandElseif, //          'elseif'
  commandEndif, //           'endif'
  commandIf, //              'if'
  commandJump, //            'jump'
  commandLocal, //           'local'
  commandSet, //             'set'
  commandStop, //            'stop'
  commandWait, //            'wait'
  constFalse, //             'false'
  constTrue, //              'true'
  endBody, //                '==='
  endCommand, //             '>>'
  endExpression, //          '}'
  endHeader, //              '---' '-'*
  endIndent, //              RegExp(r'^\s*')
  endMarkupTag, //           ']'
  endParenthesis, //         ')'
  newline, //                '\r' | '\n' | '\r\n'
  operatorAnd, //            'and' | '&&'
  operatorAssign, //         'to' | '='
  operatorDivide, //         '/'
  operatorDivideAssign, //   '/='
  operatorEqual, //          'is' | 'eq' | '=='
  operatorGreaterOrEqual, // 'ge' | 'gte' | '>='
  operatorGreaterThan, //    'gt' | '>'
  operatorLessOrEqual, //    'le' | 'lte | '<='
  operatorLessThan, //       'lt' | '<'
  operatorMinus, //          '-'
  operatorMinusAssign, //    '-='
  operatorModulo, //         '%'
  operatorModuloAssign, //   '%='
  operatorMultiply, //       '*'
  operatorMultiplyAssign, // '*='
  operatorNot, //            'not' | '!'
  operatorNotEqual, //       'ne' | 'neq' | '!='
  operatorOr, //             'or' | '||'
  operatorPlus, //           '+'
  operatorPlusAssign, //     '+='
  operatorXor, //            'xor' | '^'
  startBody, //              '---' '-'*
  startCommand, //           '<<'
  startExpression, //        '{'
  startHeader, //            ('---' '-'*)?
  startIndent, //            RegExp(r'^\s*')
  startMarkupTag, //         '['
  startParenthesis, //       '('
  typeBool, //               'bool'
  typeNumber, //             'number'
  typeString, //             'string'

  error,
  eof,
}
