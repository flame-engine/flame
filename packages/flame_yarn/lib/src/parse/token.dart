import 'package:meta/meta.dart';

/// [Token] is a unit of output during the lexing stage.
@internal
class Token {
  const Token(this.type, [this.content]);

  final TokenType type;
  final String? content;

  @override
  String toString() {
    return 'Token($type${content == null? '' : ', $content'})';
  }
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
