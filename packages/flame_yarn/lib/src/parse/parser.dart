import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:flame_yarn/src/parse/tokenize.dart';
import 'package:flame_yarn/src/structure/expressions/arithmetic.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/expressions/literal.dart';
import 'package:flame_yarn/src/structure/expressions/string.dart';
import 'package:flame_yarn/src/structure/line.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_ball.dart';
import 'package:meta/meta.dart';

@internal
void parse(String text, YarnBall project) {
  final tokens = tokenize(text);
  _Parser(project, text, tokens).parse();
}

class _Parser {
  _Parser(this.project, this.text, this.tokens) : position = 0;

  final YarnBall project;
  final String text;
  final List<Token> tokens;

  /// The index of the next token to parse.
  int position;

  bool advance() {
    position += 1;
    return true;
  }

  Token peekToken([int delta = 0]) => tokens[position + delta];

  Token nextToken() {
    final token = tokens[position];
    position += 1;
    return token;
  }

  void returnToken() {
    position -= 1;
  }

  void parse() {
    while (position < tokens.length) {
      final nodeBuilder = _NodeBuilder();
      parseNodeHeader(nodeBuilder);
      parseNodeBody(nodeBuilder);
      assert(!project.nodes.containsKey(nodeBuilder.title));
      project.nodes[nodeBuilder.title!] = nodeBuilder.build();
    }
  }

  void parseNodeHeader(_NodeBuilder node) {
    while (peekToken() != Token.startBody) {
      if (takeId() && take(Token.colon) && takeText() && takeNewline()) {
        final id = peekToken(-4);
        final text = peekToken(-2);
        if (id.content == 'title') {
          node.title = text.content;
          if (project.nodes.containsKey(node.title)) {
            error('node with title ${node.title} has already been defined');
          }
        } else {
          node.tags ??= [];
          node.tags!.add(text.content);
        }
      }
    }
    if (node.title == null) {
      error('node does not have a title');
    }
  }

  void parseNodeBody(_NodeBuilder node) {
    take(Token.startBody);
    if (peekToken() == Token.startIndent) {
      error('unexpected indent');
    }
    parseStatementList(node.statements);
    take(Token.endBody);
  }

  void parseStatementList(List<Statement> out) {
    while (true) {
      final nextToken = peekToken();
      if (nextToken == Token.arrow) {
        parseOption();
      } else if (nextToken == Token.startCommand) {
        parseCommand();
      } else if (nextToken.isText || nextToken.isSpeaker) {
        final lineBuilder = _LineBuilder();
        parseLine(lineBuilder);
        out.add(lineBuilder.build());
      } else {
        break;
      }
    }
  }

  void parseOption() {}

  void parseCommand() {}

  /// Consumes a regular line of text from the input, up to and including the
  /// NEWLINE token.
  void parseLine(_LineBuilder line) {
    maybeParseLineSpeaker(line);
    parseLineContent(line);
    maybeParseLineCondition(line);
    maybeParseHashtags(line);
    if (peekToken() == Token.startCommand) {
      if (line.tags != null) {
        error('the command must come before the hashtags');
      } else {
        error('multiple commands are not allowed on a line');
      }
    }
    takeNewline();
  }

  void maybeParseLineSpeaker(_LineBuilder line) {
    final token = peekToken();
    if (token.isSpeaker) {
      line.speaker = token.content;
      takeSpeaker();
      take(Token.colon);
    }
  }

  void parseLineContent(_LineBuilder line) {
    final parts = <TypedExpression<String>>[];
    while (true) {
      final token = peekToken();
      if (token.isText) {
        parts.add(Literal<String>(token.content));
      } else if (token == Token.startExpression) {
        final expressionBuilder = _ExpressionBuilder<String>();
        take(Token.startExpression);
        parseExpression(expressionBuilder);
        take(Token.endExpression);
      } else {
        break;
      }
    }
    if (parts.length == 1) {
      line.content = parts.first;
    } else if (parts.length > 1) {
      line.content = Concat(parts);
    }
  }

  void maybeParseLineCondition(_LineBuilder line) {
    final token = peekToken();
    if (token == Token.startCommand) {
      position += 1;
      if (peekToken() != Token.commandIf) {
        error('only if commands are allowed on a line');
      }
      position += 1;

      take(Token.endCommand);
    }
  }

  void maybeParseHashtags(_LineBuilder line) {
    while (true) {
      final token = peekToken();
      if (token.isHashtag) {
        line.tags ??= [];
        line.tags!.add(token.content);
        position += 1;
      } else {
        break;
      }
    }
  }

  void parseExpression(_ExpressionBuilder<String> expression) {}

  Expression parseExpression2() {
    Expression parsePrimary() {
      final token = peekToken();
      position += 1;
      if (token == Token.startParenthesis) {
        final expression = parse_expression();
        if (peekToken() != Token.endParenthesis) {
          error('closing ) is expected');
        }
        return expression;
      } else if (token == Token.operatorMinus) {
        final expression = parsePrimary();
        if (expression is Literal<num>) {
          return Literal<num>(-expression.value);
        } else if (expression.type == ExpressionType.numeric) {
          return UnaryMinus(expression);
        } else {
          error('unary - can only be applied to numbers');
        }
      } else if (token.isNumber) {
        return Literal<num>(num.parse(token.content));
      } else if (token.isString) {
        return Literal<String>(token.content);
      } else if (token.isVariable) {
        return Variable(token.content);
      }
      throw UnimplementedError();
    }

    Expression parse_expression1(Expression lhs, int min_precedence) {
      var result = lhs;
      var token = peekToken();
      while ((binaryOperatorsPrecedence[token] ?? -1) >= min_precedence) {
        final op = token;
        position += 1;
        final rhs = parsePrimary();
        token = peekToken();
      }
      return result;
    }

    Expression parse_expression() => parse_expression1(parsePrimary(), 0);
    throw UnimplementedError();
  }

  //----------------------------------------------------------------------------
  // All `take*` methods will consume a single token of the specified kind,
  // advance the parsing [position], and return `true` (for chaining purposes).
  // If, on the other hand, the specified token cannot be found, an exception
  // 'unexpected token' will be thrown.
  //----------------------------------------------------------------------------

  bool takeId() => takeTokenType(TokenType.id);
  bool takeText() => takeTokenType(TokenType.text);
  bool takeSpeaker() => takeTokenType(TokenType.speaker);
  bool takeNewline() => take(Token.newline);

  bool take(Token token) {
    if (tokens[position] == token) {
      position += 1;
      return true;
    }
    return error('unexpected token');
  }

  bool takeTokenType(TokenType type) {
    if (tokens[position].type == type) {
      position += 1;
      return true;
    }
    return error('unexpected token');
  }

  static const Map<Token, int> binaryOperatorsPrecedence = {
    Token.operatorMultiply: 6,
    Token.operatorDivide: 6,
    Token.operatorModulo: 6,
    //
    Token.operatorMinus: 5,
    Token.operatorPlus: 5,
    //
    Token.operatorEqual: 4,
    Token.operatorNotEqual: 4,
    Token.operatorGreaterOrEqual: 4,
    Token.operatorGreaterThan: 4,
    Token.operatorLessOrEqual: 4,
    Token.operatorLessThan: 4,
    //
    Token.operatorNot: 3,
    Token.operatorAnd: 2,
    Token.operatorXor: 2,
    Token.operatorOr: 1,
  };

  static const Map<Token, _BinaryExpressionFn> binaryOperatorConstructors = {
    Token.operatorMultiply: Multiply.new,
  };

  bool error(String message) {
    throw SyntaxError(message);
  }
}

class _NodeBuilder {
  String? title;
  List<String>? tags;
  List<Statement> statements = [];

  Node build() => Node(
        title: title!,
        tags: tags,
        lines: statements,
      );
}

class _LineBuilder {
  String? speaker;
  TypedExpression<String>? content;
  TypedExpression<bool>? condition;
  List<String>? tags;

  Line build() => Line(
        speaker: speaker,
        content: content ?? constEmptyString,
        condition: condition,
        tags: tags,
      );
}

class _CommandBuilder {
  String? command;
}

class _ExpressionBuilder<T> {
  TypedExpression<T> build() => throw 'error';
}

typedef Expr = Expression;
typedef _BinaryExpressionFn = Expression Function(
    Expression, Expression);
