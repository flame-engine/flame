import 'package:jenny/src/errors.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/commands/if_command.dart';
import 'package:jenny/src/structure/commands/jump_command.dart';
import 'package:jenny/src/structure/commands/set_command.dart';
import 'package:jenny/src/structure/commands/stop_command.dart';
import 'package:jenny/src/structure/commands/wait_command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/expressions/arithmetic.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:jenny/src/structure/expressions/logical.dart';
import 'package:jenny/src/structure/expressions/relational.dart';
import 'package:jenny/src/structure/expressions/string.dart';
import 'package:jenny/src/structure/expressions/variables.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/structure/option.dart';
import 'package:jenny/src/structure/statement.dart';
import 'package:jenny/src/yarn_project.dart';
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

  void parseMain() {
    while (position < tokens.length) {
      final header = parseNodeHeader();
      final block = parseNodeBody();
      project.nodes[header.title!] = Node(
        title: header.title!,
        tags: header.tags,
        content: block,
      );
    }
  }

  _NodeHeader parseNodeHeader() {
    String? title;
    final tags = <String, String>{};
    take(Token.startHeader);
    while (peekToken() != Token.endHeader) {
      if (takeId() && take(Token.colon) && takeText() && takeNewline()) {
        final id = peekToken(-4);
        final text = peekToken(-2);
        if (id.content == 'title') {
          if (title != null) {
            position -= 4;
            syntaxError('a node can only have one title');
          }
          title = text.content;
          if (project.nodes.containsKey(title)) {
            position -= 4;
            nameError(
              'node with title "$title" has already been defined',
            );
          }
        } else {
          tags[id.content] = text.content;
        }
      }
    }
    take(Token.endHeader);
    if (title == null) {
      syntaxError('node does not have a title');
    }
    return _NodeHeader(title, tags.isEmpty ? null : tags);
  }

  Block parseNodeBody() {
    take(Token.startBody);
    if (peekToken() == Token.startIndent) {
      syntaxError('unexpected indent');
    }
    final out = parseStatementList();
    take(Token.endBody);
    return out;
  }

  Block parseStatementList() {
    final lines = <Statement>[];
    while (true) {
      final nextToken = peekToken();
      if (nextToken == Token.arrow) {
        final option = parseOption();
        if (lines.isNotEmpty && lines.last is DialogueChoice) {
          (lines.last as DialogueChoice).options.add(option);
        } else {
          lines.add(DialogueChoice([option]));
        }
      } else if (nextToken == Token.startCommand) {
        lines.add(parseCommand());
      } else if (nextToken.isText ||
          nextToken.isPerson ||
          nextToken == Token.startExpression) {
        lines.add(parseDialogueLine());
      } else {
        break;
      }
    }
    return Block(lines);
  }

  //#region Line parsing

  /// Consumes a regular line of text from the input, up to and including the
  /// NEWLINE token.
  DialogueLine parseDialogueLine() {
    final person = maybeParseLinePerson();
    final content = parseLineContent();
    final tags = maybeParseHashtags();
    if (peekToken() == Token.startCommand) {
      syntaxError('commands are not allowed on a dialogue line');
    }
    takeNewline();
    return DialogueLine(
      character: person,
      content: content,
      tags: tags,
    );
  }

  Option parseOption() {
    take(Token.arrow);
    final person = maybeParseLinePerson();
    final content = parseLineContent();
    final condition = maybeParseLineCondition();
    final tags = maybeParseHashtags();
    if (peekToken() == Token.startCommand) {
      syntaxError('multiple commands are not allowed on an option line');
    }
    take(Token.newline);
    var block = const Block.empty();
    if (peekToken() == Token.startIndent) {
      position += 1;
      block = parseStatementList();
      take(Token.endIndent);
    }
    return Option(
      content: content,
      character: person,
      tags: tags,
      condition: condition,
      block: block,
    );
  }

  String? maybeParseLinePerson() {
    final token = peekToken();
    if (token.isPerson) {
      takePerson();
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
      return Concatenate(parts);
    } else {
      return constEmptyString;
    }
  }

  BoolExpression? maybeParseLineCondition() {
    final token = peekToken();
    if (token == Token.startCommand) {
      position += 1;
      if (peekToken() != Token.commandIf) {
        syntaxError('only "if" command is allowed for an option');
      }
      position += 1;
      take(Token.startExpression);
      final position0 = position;
      final expression = parseExpression();
      take(Token.endExpression);
      if (!expression.isBoolean) {
        position = position0;
        typeError('the condition in "if" should be boolean');
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

  //#endregion

  //#region Commands parsing
  //----------------------------------------------------------------------------
  // COMMANDS
  //
  // The commands are the control structures of Yarn. Each builtin command has
  // its own syntax, and therefore has to be parsed separately. In addition,
  // there are also user-defined commands.
  //
  // See https://github.com/YarnSpinnerTool/YarnSpinner/blob/main/Documentation/Yarn-Spec.md#commands
  //----------------------------------------------------------------------------

  /// Parses and returns any line or multi-line command. On the other hand, this
  /// function should not be used to parse line conditionals (i.e. commands at
  /// the end of the line).
  Command parseCommand() {
    assert(peekToken() == Token.startCommand);
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
    } else if (token == Token.commandElseif ||
        token == Token.commandElse ||
        token == Token.commandEndif) {
      position += 1;
      syntaxError('this command is only allowed after an <<if>>');
    } else {
      assert(token.isCommand, 'unimplemented $token');
      return parseUserDefinedCommand();
    }
  }

  /// Parses the <<if>> command, and the subsequent <<elseif>>, <<else>>, up to
  /// and including the <<endif>>.
  Command parseCommandIf() {
    final parts = <IfBlock>[];
    parts.add(parseCommandIfBlock('if'));

    var hasElse = false;
    while (true) {
      final command = peekToken(1);
      if (command == Token.commandElseif) {
        parts.add(parseCommandIfBlock('elseif'));
      } else if (command == Token.commandElse) {
        if (hasElse) {
          syntaxError('only one <<else>> is allowed');
        }
        parts.add(parseCommandElseBlock());
        hasElse = true;
      } else if (command == Token.commandEndif) {
        take(Token.startCommand);
        take(Token.commandEndif);
        take(Token.endCommand);
        takeNewline();
        break;
      } else {
        syntaxError('<<endif>> expected');
      }
    }
    return IfCommand(parts);
  }

  IfBlock parseCommandIfBlock(String commandName) {
    take(Token.startCommand);
    take(commandName == 'if' ? Token.commandIf : Token.commandElseif);
    take(Token.startExpression);
    final position0 = position;
    final expression = parseExpression();
    if (!expression.isBoolean) {
      position = position0;
      typeError('expression in an <<$commandName>> command must be boolean');
    }
    take(Token.endExpression);
    take(Token.endCommand);
    take(Token.newline);
    if (peekToken() == Token.startCommand) {
      return IfBlock(expression as BoolExpression, const Block.empty());
    }
    if (peekToken() != Token.startIndent) {
      syntaxError('the body of the <<$commandName>> command must be indented');
    }
    take(Token.startIndent);
    final block = parseStatementList();
    take(Token.endIndent);
    return IfBlock(expression as BoolExpression, block);
  }

  IfBlock parseCommandElseBlock() {
    take(Token.startCommand);
    take(Token.commandElse);
    take(Token.endCommand);
    take(Token.newline);
    if (peekToken() == Token.startCommand) {
      return const IfBlock(constTrue, Block.empty());
    }
    if (peekToken() != Token.startIndent) {
      syntaxError('the body of the <<else>> command must be indented');
    }
    take(Token.startIndent);
    final statements = parseStatementList();
    take(Token.endIndent);
    return IfBlock(constTrue, statements);
  }

  Command parseCommandJump() {
    take(Token.startCommand);
    take(Token.commandJump);
    final token = peekToken();
    StringExpression target;
    if (token.isId) {
      // TODO(st-pasha): add verification for node existence at the end of
      //                 project setup
      target = StringLiteral(token.content);
      position += 1;
    } else {
      take(Token.startExpression);
      final expression = parseExpression();
      take(Token.endExpression);
      if (expression.isString) {
        target = expression as StringExpression;
      } else {
        typeError('target of <<jump>> must be a string expression');
      }
    }
    take(Token.endCommand);
    take(Token.newline);
    return JumpCommand(target);
  }

  Command parseCommandStop() {
    take(Token.startCommand);
    take(Token.commandStop);
    take(Token.endCommand);
    take(Token.newline);
    return const StopCommand();
  }

  Command parseCommandWait() {
    take(Token.startCommand);
    take(Token.commandWait);
    final expression = parseExpression();
    if (!expression.isNumeric) {
      typeError('<<wait>> command expects a numeric argument');
    }
    take(Token.endCommand);
    take(Token.newline);
    return WaitCommand(expression as NumExpression);
  }

  Command parseCommandSet() {
    take(Token.startCommand);
    take(Token.commandSet);
    final variableToken = peekToken();
    if (variableToken.isVariable) {
      position += 1;
    } else {
      syntaxError('variable expected');
    }
    final variableName = variableToken.content;
    final variableExists = project.variables.hasVariable(variableName);
    final assignmentToken = peekToken();
    if (assignmentTokens.contains(assignmentToken)) {
      position += 1;
    } else {
      syntaxError('an assignment operator is expected');
    }
    final expression = parseExpression();
    if (variableExists) {
      final variableType = project.variables.getVariableType(variableName);
      if (variableType != expression.type) {
        typeError(
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
    take(Token.newline);
    return SetCommand(variableName, expression);
  }

  Command parseUserDefinedCommand() {
    throw UnimplementedError('user-defined commands are not supported yet');
  }

  static const List<Token> assignmentTokens = [
    Token.operatorAssign,
    Token.operatorDivideAssign,
    Token.operatorMinusAssign,
    Token.operatorModuloAssign,
    Token.operatorMultiplyAssign,
    Token.operatorPlusAssign,
  ];

  //#endregion

  //#region Expression parsing
  //----------------------------------------------------------------------------
  // EXPRESSIONS
  //
  // Expressions are the mathematical notation used within the commands and
  // interpolated text in order to perform calculations at runtime.
  //
  // See https://github.com/YarnSpinnerTool/YarnSpinner/blob/main/Documentation/Yarn-Spec.md#expressions
  //----------------------------------------------------------------------------

  /// Parses an expression starting from the current [position], and up to the
  /// point where we encounter a token that cannot be interpreted as part of an
  /// expression. Note that the startExpression / endExpressions tokens are not
  /// consumed (nor required) by this method. This makes it suitable to use
  /// this method to both extract an interpolated text expression, and a command
  /// expression.
  ///
  /// If an expression cannot be parsed at the current location at all, the
  /// [constVoid] will be returned.
  Expression parseExpression() {
    // We're using the Operator-Precedence parsing algorithm here, see
    // https://en.wikipedia.org/wiki/Operator-precedence_parser
    final lhs = parsePrimary();
    return _parseExpressionImpl(lhs, 0);
  }

  /// This is an implementation function for the Operator-Precedence parsing
  /// algorithm. It consumes expressions of the form `LHS op RHS op...`, where
  /// the precedence of operators must be greater or equal to [minPrecedence].
  /// The initial [lhs] sub-expression is provided, and the parsing position
  /// should be at the start of the next operator.
  Expression _parseExpressionImpl(Expression lhs, int minPrecedence) {
    var position0 = position;
    var result = lhs;
    while ((precedences[peekToken()] ?? -1) >= minPrecedence) {
      final op = peekToken();
      final opPrecedence = precedences[op]!;
      position += 1;
      var rhs = parsePrimary();
      if (rhs == constVoid) {
        syntaxError('unexpected expression');
      }
      var token = peekToken();
      while ((precedences[token] ?? -1) > opPrecedence) {
        rhs = _parseExpressionImpl(rhs, opPrecedence + 1);
        token = peekToken();
        position0 = position;
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
        syntaxError('missing closing ")"');
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
        typeError('unary minus can only be applied to numbers');
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
        nameError('variable $name is not defined');
      }
    } else if (token.isId) {
      throw UnimplementedError();
    } else if (token == Token.operatorNot) {
      final position0 = position;
      final lhs = parsePrimary();
      final arg = _parseExpressionImpl(lhs, precedences[Token.operatorNot]!);
      if (!arg.isBoolean) {
        position = position0;
        typeError('operator `not` can only be applied to booleans');
      }
      return LogicalNot(arg as BoolExpression);
    }
    position -= 1;
    return constVoid;
  }

  Expression _add(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Add(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return Concatenate([lhs as StringExpression, rhs as StringExpression]);
    }
    position = opPosition;
    typeError('both lhs and rhs of + must be numeric or strings');
  }

  Expression _subtract(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Subtract(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return Remove(lhs as StringExpression, rhs as StringExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of - must be numeric or strings');
  }

  Expression _multiply(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Multiply(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of * must be numeric');
  }

  Expression _divide(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Divide(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of / must be numeric');
  }

  Expression _modulo(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Modulo(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of % must be numeric');
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
    typeError(
      'equality operator between operands of unrelated types ${lhs.type.name} '
      'and ${rhs.type.name}',
    );
  }

  Expression _notEqual(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return NumericNotEqual(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return StringNotEqual(lhs as StringExpression, rhs as StringExpression);
    }
    if (lhs.isBoolean && rhs.isBoolean) {
      return BoolNotEqual(lhs as BoolExpression, rhs as BoolExpression);
    }
    position = opPosition;
    typeError(
      'inequality operator between operands of unrelated types '
      '${lhs.type.name} and ${rhs.type.name}',
    );
  }

  Expression _greaterOrEqual(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return GreaterThanOrEqual(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of ">=" must be numeric');
  }

  Expression _greaterThan(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return GreaterThan(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of ">" must be numeric');
  }

  Expression _lessOrEqual(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return LessThanOrEqual(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of "<=" must be numeric');
  }

  Expression _lessThan(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return LessThan(lhs as NumExpression, rhs as NumExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of "<" must be numeric');
  }

  Expression _and(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return LogicalAnd(lhs as BoolExpression, rhs as BoolExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of "&&" must be boolean');
  }

  Expression _or(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return LogicalOr(lhs as BoolExpression, rhs as BoolExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of "||" must be boolean');
  }

  Expression _xor(Expression lhs, Expression rhs, int opPosition) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return LogicalXor(lhs as BoolExpression, rhs as BoolExpression);
    }
    position = opPosition;
    typeError('both lhs and rhs of "^" must be boolean');
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
    Token.operatorNotEqual: _notEqual,
    Token.operatorGreaterOrEqual: _greaterOrEqual,
    Token.operatorGreaterThan: _greaterThan,
    Token.operatorLessOrEqual: _lessOrEqual,
    Token.operatorLessThan: _lessThan,
    Token.operatorAnd: _and,
    Token.operatorOr: _or,
    Token.operatorXor: _xor,
  };

  //#endregion

  //----------------------------------------------------------------------------
  // All `take*` methods will consume a single token of the specified kind,
  // advance the parsing [position], and return `true` (for chaining purposes).
  // If, on the other hand, the specified token cannot be found, an exception
  // 'unexpected token' will be thrown.
  //----------------------------------------------------------------------------

  Token peekToken([int delta = 0]) {
    return position + delta < tokens.length
        ? tokens[position + delta]
        : Token.eof;
  }

  bool takeId() => takeTokenType(TokenType.id);
  bool takeText() => takeTokenType(TokenType.text);
  bool takePerson() => takeTokenType(TokenType.person);
  bool takeNewline() => take(Token.newline);

  bool take(Token token) {
    if (tokens[position] == token) {
      position += 1;
      return true;
    }
    return syntaxError('unexpected token');
  }

  bool takeTokenType(TokenType type) {
    if (tokens[position].type == type) {
      position += 1;
      return true;
    }
    return syntaxError('unexpected token');
  }

  Never nameError(String message) => _error(message, NameError.new);
  Never syntaxError(String message) => _error(message, SyntaxError.new);
  Never typeError(String message) => _error(message, TypeError.new);

  Never _error(String message, Exception Function(String) errorConstructor) {
    final newTokens = tokenize(text, addErrorTokenAtIndex: position);
    final errorToken = newTokens[position];
    final location = errorToken.content;
    throw errorConstructor('$message\n$location\n');
  }
}

class _NodeHeader {
  _NodeHeader(this.title, this.tags);
  String? title;
  Map<String, String>? tags;
}
