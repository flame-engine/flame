import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:flame_yarn/src/parse/tokenize.dart';
import 'package:flame_yarn/src/structure/dialogue.dart';
import 'package:flame_yarn/src/structure/expressions/arithmetic.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/structure/expressions/functions.dart';
import 'package:flame_yarn/src/structure/expressions/literal.dart';
import 'package:flame_yarn/src/structure/expressions/relational.dart';
import 'package:flame_yarn/src/structure/expressions/string.dart';
import 'package:flame_yarn/src/structure/expressions/variables.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/option.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_project.dart';
import 'package:meta/meta.dart';

@internal
void parse(String text, YarnProject project) {
  final tokens = tokenize(text);
  _Parser(project, text, tokens).parseMain();
}

class _Parser {
  _Parser(this.project, this.text, this.tokens) : position = 0;

  final YarnProject project;
  final String text;
  final List<Token> tokens;

  /// The index of the next token to parse.
  int position;

  Token peekToken([int delta = 0]) => tokens[position + delta];

  void parseMain() {
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
          if (node.title != null) {
            position -= 4;
            error('a node can only have one title');
          }
          node.title = text.content;
          if (project.nodes.containsKey(node.title)) {
            position -= 4;
            error('node with title "${node.title}" has already been defined');
          }
        } else {
          node.tags ??= {};
          node.tags![id.content] = text.content;
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
        out.add(parseOption());
      } else if (nextToken == Token.startCommand) {
        parseCommand();
      } else if (nextToken.isText ||
          nextToken.isSpeaker ||
          nextToken == Token.startExpression) {
        out.add(parseDialogueLine());
      } else {
        break;
      }
    }
  }

  /// Consumes a regular line of text from the input, up to and including the
  /// NEWLINE token.
  Dialogue parseDialogueLine() {
    final line = _DialogueBuilder();
    maybeParseLineSpeaker(line);
    parseLineContent(line);
    maybeParseHashtags(line);
    if (peekToken() == Token.startCommand) {
      error('commands are not allowed on a dialogue line');
    }
    takeNewline();
    return line.build() as Dialogue;
  }

  Option parseOption() {
    final optionBuilder = _OptionBuilder();
    take(Token.arrow);
    maybeParseLineSpeaker(optionBuilder);
    parseLineContent(optionBuilder);
    optionBuilder.condition = maybeParseLineCondition();
    maybeParseHashtags(optionBuilder);
    if (peekToken() == Token.startCommand) {
      error('multiple commands are not allowed on a line');
    }
    take(Token.newline);
    return optionBuilder.build() as Option;
  }

  void parseCommand() {}

  void maybeParseLineSpeaker(_DialogueBuilder line) {
    final token = peekToken();
    if (token.isSpeaker) {
      line.speaker = token.content;
      takeSpeaker();
      take(Token.colon);
    }
  }

  void parseLineContent(_DialogueBuilder line) {
    final parts = <StringExpression>[];
    while (true) {
      final token = peekToken();
      if (token.isText) {
        parts.add(StringLiteral(token.content));
        position += 1;
      } else if (token == Token.startExpression) {
        take(Token.startExpression);
        final expression = parseExpression();
        if (expression.isString) {
          parts.add(expression as StringExpression);
        } else if (expression.isNumeric) {
          parts.add(NumToStringFn(expression as NumExpression));
        } else if (expression.isBoolean) {
          parts.add(BoolToStringFn(expression as BoolExpression));
        }
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

  BoolExpression? maybeParseLineCondition() {
    final token = peekToken();
    if (token == Token.startCommand) {
      position += 1;
      if (peekToken() != Token.commandIf) {
        error('only "if" command is allowed for an option');
      }
      position += 1;
      take(Token.startExpression);
      final position0 = position;
      final expression = parseExpression();
      take(Token.endExpression);
      if (!expression.isBoolean) {
        position = position0;
        error('the condition in "if" should be boolean');
      }
      take(Token.endCommand);
      return expression as BoolExpression;
    }
    return null;
  }

  void maybeParseHashtags(_DialogueBuilder line) {
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

  Expression parseExpression() {
    return parseExpression1(parsePrimary(), 0);
  }

  Expression parseExpression1(Expression lhs, int minPrecedence) {
    final position0 = position;
    var result = lhs;
    var token = peekToken();
    while ((precedences[token] ?? -1) >= minPrecedence) {
      final opPrecedence = precedences[token]!;
      final op = token;
      position += 1;
      var rhs = parsePrimary();
      if (rhs is VoidLiteral) {
        error('unexpected expression');
      }
      token = peekToken();
      while ((precedences[token] ?? -1) > opPrecedence) {
        rhs = parseExpression1(rhs, opPrecedence + 1);
        token = peekToken();
      }
      result = binaryOperatorConstructors[op]!(result, rhs, position0);
    }
    return result;
  }

  Expression parsePrimary() {
    final token = peekToken();
    position += 1;
    if (token == Token.startParenthesis) {
      final expression = parseExpression();
      if (peekToken() != Token.endParenthesis) {
        error('missing closing ")"');
      }
      position += 1;
      return expression;
    } else if (token == Token.operatorMinus) {
      final expression = parsePrimary();
      if (expression is NumLiteral) {
        return NumLiteral(-expression.value);
      } else if (expression.isNumeric) {
        return Negate(expression as NumExpression);
      } else {
        position -= 1;
        error('unary minus can only be applied to numbers');
      }
    } else if (token.isNumber) {
      return NumLiteral(num.parse(token.content));
    } else if (token.isString) {
      return StringLiteral(token.content);
    } else if (token == Token.constTrue || token == Token.constFalse) {
      return BoolLiteral(token == Token.constTrue);
    } else if (token.isVariable) {
      final name = token.content;
      if (project.variables.hasVariable(name)) {
        final dynamic variable = project.variables.getVariable(name);
        if (variable is num) {
          return NumericVariable(name, project.variables);
        } else if (variable is String) {
          return StringVariable(name, project.variables);
        } else {
          assert(variable is bool);
          return BooleanVariable(name, project.variables);
        }
      } else {
        position -= 1;
        error('variable $name is not defined', NameError.new);
      }
    } else if (token.isId) {
      // A function call...
    }
    position -= 1;
    return constVoid;
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

  static final Map<Token, int> precedences = {
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

  late Map<Token, Expression Function(Expression, Expression, int)>
      binaryOperatorConstructors = {
    Token.operatorDivide: _divide,
    Token.operatorMinus: _subtract,
    Token.operatorModulo: _modulo,
    Token.operatorMultiply: _multiply,
    Token.operatorPlus: _add,
    Token.operatorEqual: _equal,
  };

  Expression _add(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Add(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return Concat([lhs as StringExpression, rhs as StringExpression]);
    }
    position = opPosition;
    error('both lhs and rhs of + must be numeric or strings');
  }

  Expression _subtract(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Subtract(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return Remove(lhs as StringExpression, rhs as StringExpression);
    }
    position = opPosition;
    error('both lhs and rhs of - must be numeric or strings');
  }

  Expression _multiply(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Multiply(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isNumeric) {
      return Repeat(lhs as StringExpression, rhs as NumExpression);
    }
    position = opPosition;
    error('both lhs and rhs of * must be numeric');
  }

  Expression _divide(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Divide(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    error('both lhs and rhs of / must be numeric');
  }

  Expression _modulo(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Modulo(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    error('both lhs and rhs of % must be numeric');
  }

  Expression _equal(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return NumericEqual(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return StringEqual(lhs as StringExpression, rhs as StringExpression);
    }
    if (lhs.isBoolean && rhs.isBoolean) {
      return BoolEqual(lhs as BoolExpression, rhs as BoolExpression);
    }
    position = opPosition;
    error(
      'equality operator between operands of unrelated types ${lhs.type.name} '
      'and ${rhs.type.name}',
    );
  }

  Never error(
    String message, [
    Exception Function(String) errorConstructor = SyntaxError.new,
  ]) {
    final newTokens = tokenize(text, addErrorTokenAtIndex: position);
    final errorToken = newTokens[position];
    final location = errorToken.content;
    throw errorConstructor('$message\n$location\n');
  }
}

class _NodeBuilder {
  String? title;
  Map<String, String>? tags;
  List<Statement> statements = [];

  Node build() => Node(
        title: title!,
        tags: tags,
        lines: statements,
      );
}

class _DialogueBuilder {
  String? speaker;
  StringExpression? content;
  List<String>? tags;

  Statement build() => Dialogue(
        speaker: speaker,
        content: content ?? constEmptyString,
        tags: tags,
      );
}

class _OptionBuilder extends _DialogueBuilder {
  BoolExpression? condition;
  List<Statement>? block;

  @override
  Statement build() => Option(
        content: content ?? constEmptyString,
        speaker: speaker,
        tags: tags,
        condition: condition,
        block: block ?? const <Statement>[],
      );
}
