import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:flame_yarn/src/parse/tokenize.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/commands/if_command.dart';
import 'package:flame_yarn/src/structure/commands/jump_command.dart';
import 'package:flame_yarn/src/structure/commands/set_command.dart';
import 'package:flame_yarn/src/structure/commands/stop_command.dart';
import 'package:flame_yarn/src/structure/commands/wait_command.dart';
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
      final nodeBuilder = parseNodeHeader();
      nodeBuilder.statements = parseNodeBody();
      assert(!project.nodes.containsKey(nodeBuilder.title));
      project.nodes[nodeBuilder.title!] = nodeBuilder.build();
    }
  }

  _NodeBuilder parseNodeHeader() {
    final node = _NodeBuilder();
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
            error(
              'node with title "${node.title}" has already been defined',
              NameError.new,
            );
          }
        } else {
          node.tags ??= {};
          node.tags![id.content] = text.content;
        }
      }
    }
    if (node.title == null) {
      error('node does not have a title', NameError.new);
    }
    return node;
  }

  List<Statement> parseNodeBody() {
    final out = <Statement>[];
    take(Token.startBody);
    if (peekToken() == Token.startIndent) {
      error('unexpected indent');
    }
    out.addAll(parseStatementList());
    take(Token.endBody);
    return out;
  }

  List<Statement> parseStatementList() {
    final result = <Statement>[];
    while (true) {
      final nextToken = peekToken();
      if (nextToken == Token.arrow) {
        result.add(parseOption());
      } else if (nextToken == Token.startCommand) {
        parseCommand();
      } else if (nextToken.isText ||
          nextToken.isSpeaker ||
          nextToken == Token.startExpression) {
        result.add(parseDialogueLine());
      } else {
        break;
      }
    }
    return result;
  }

  /// Consumes a regular line of text from the input, up to and including the
  /// NEWLINE token.
  Dialogue parseDialogueLine() {
    final speaker = maybeParseLineSpeaker();
    final content = parseLineContent();
    final tags = maybeParseHashtags();
    if (peekToken() == Token.startCommand) {
      error('commands are not allowed on a dialogue line');
    }
    takeNewline();
    return Dialogue(
      speaker: speaker,
      content: content,
      tags: tags,
    );
  }

  Option parseOption() {
    take(Token.arrow);
    final speaker = maybeParseLineSpeaker();
    final content = parseLineContent();
    final condition = maybeParseLineCondition();
    final tags = maybeParseHashtags();
    if (peekToken() == Token.startCommand) {
      error('multiple commands are not allowed on a line');
    }
    take(Token.newline);
    var block = const <Statement>[];
    if (peekToken() == Token.startIndent) {
      position += 1;
      block = parseStatementList();
      take(Token.endIndent);
    }
    return Option(
      content: content,
      speaker: speaker,
      tags: tags,
      condition: condition,
      block: block,
    );
  }

  Command parseCommand() {
    final token = peekToken(1);
    if (token == Token.commandIf) {
      return parseCommandIf();
    } else if (token == Token.commandJump) {
      return parseCommandJump();
    } else if (token == Token.commandStop) {
      return parseCommandStop();
    } else if (token == Token.commandWait) {
      return parseCommandWait();
    } else if (token == Token.commandSet) {
      return parseCommandSet();
    }
    throw UnimplementedError();
  }

  Command parseCommandIf() {
    final parts = <IfBlock>[];
    var hasElse = false;
    while (true) {
      take(Token.startCommand);
      final command = peekToken();
      if (command == (parts.isEmpty ? Token.commandIf : Token.commandElseif)) {
        take(command);
        final position0 = position;
        final expression = parseExpression();
        if (!expression.isBoolean) {
          position = position0;
          final name = command == Token.commandIf ? 'if' : 'elseif';
          error('expression in an a <<$name>> command must be boolean');
        }
        take(Token.endCommand);
        take(Token.newline);
        take(Token.startIndent);
        final statements = parseStatementList();
        parts.add(IfBlock(expression as BoolExpression, statements));
        take(Token.endIndent);
      } else if (command == Token.commandElse) {
        if (hasElse) {
          error('only one <<else>> is allowed');
        }
        hasElse = true;
        take(command);
        take(Token.endCommand);
        take(Token.newline);
        take(Token.startIndent);
        final statements = parseStatementList();
        parts.add(IfBlock(constTrue, statements));
        take(Token.endIndent);
      } else if (command == Token.commandEndif) {
        take(command);
        take(Token.endCommand);
        takeNewline();
        break;
      } else {
        error('<<endif>> expected');
      }
    }
    return IfCommand(parts);
  }

  Command parseCommandJump() {
    take(Token.startCommand);
    take(Token.commandJump);
    final token = peekToken();
    StringExpression target;
    if (token.isId) {
      target = StringLiteral(token.content);
    } else {
      take(Token.startExpression);
      final expression = parseExpression();
      take(Token.endExpression);
      if (expression.isString) {
        target = expression as StringExpression;
      } else {
        error('target of <<jump>> must be a string expression');
      }
    }
    take(Token.endCommand);
    return JumpCommand(target);
  }

  Command parseCommandStop() {
    take(Token.startCommand);
    take(Token.commandStop);
    take(Token.endCommand);
    return const StopCommand();
  }

  Command parseCommandWait() {
    take(Token.startCommand);
    take(Token.commandWait);
    final expression = parseExpression();
    if (!expression.isNumeric) {
      error('<<wait>> command expects a numeric argument');
    }
    take(Token.endCommand);
    return WaitCommand(expression as NumExpression);
  }

  Command parseCommandSet() {
    take(Token.startCommand);
    take(Token.commandSet);
    final variableToken = peekToken();
    if (variableToken.isVariable) {
      position += 1;
    } else {
      error('variable expected');
    }
    final variableName = variableToken.content;
    final variableExists = project.variables.hasVariable(variableName);
    final assignmentToken = peekToken();
    if (assignmentTokens.contains(assignmentToken)) {
      position += 1;
    } else {
      error('an assignment operator is expected');
    }
    final expression = parseExpression();
    if (variableExists) {
      final variableType = project.variables.getVariableType(variableName);
      if (variableType != expression.type) {
        error(
          'variable $variableName of type ${variableType.name} cannot be '
          'assigned a value of type ${expression.type.name}',
        );
      }
    } else {
      final variableType = expression.type;
      final dynamic initialValue = variableType is String
          ? ''
          : variableType is num
              ? 0
              : variableType is bool
                  ? false
                  : null;
      project.variables.setVariable(variableName, initialValue);
      assert(project.variables.getVariableType(variableName) == variableType);
    }
    if (assignmentToken != Token.operatorAssign) {
      if (!variableExists) {
        nameError('variable $variableName was not defined');
      }
      throw UnimplementedError();
    }
    take(Token.endCommand);
    return SetCommand(variableName, expression);
  }

  String? maybeParseLineSpeaker() {
    final token = peekToken();
    if (token.isSpeaker) {
      takeSpeaker();
      take(Token.colon);
      return token.content;
    }
    return null;
  }

  StringExpression parseLineContent() {
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
      return parts.first;
    } else if (parts.length > 1) {
      return Concat(parts);
    } else {
      return constEmptyString;
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

  List<String>? maybeParseHashtags() {
    final out = <String>[];
    while (true) {
      final token = peekToken();
      if (token.isHashtag) {
        out.add(token.content);
        position += 1;
      } else {
        break;
      }
    }
    return out.isEmpty ? null : out;
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

  static const List<Token> assignmentTokens = [
    Token.operatorAssign,
    Token.operatorDivideAssign,
    Token.operatorMinusAssign,
    Token.operatorModuloAssign,
    Token.operatorMultiplyAssign,
    Token.operatorPlusAssign,
  ];

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

  Never nameError(String message) => error(message, NameError.new);
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
