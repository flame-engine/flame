import 'package:jenny/src/errors.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/commands/declare_command.dart';
import 'package:jenny/src/structure/commands/if_command.dart';
import 'package:jenny/src/structure/commands/jump_command.dart';
import 'package:jenny/src/structure/commands/local_command.dart';
import 'package:jenny/src/structure/commands/set_command.dart';
import 'package:jenny/src/structure/commands/stop_command.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:jenny/src/structure/commands/wait_command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/dialogue_option.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/structure/expressions/functions/string.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart'
    hide ErrorFn;
import 'package:jenny/src/structure/expressions/operators/negate.dart';
import 'package:jenny/src/structure/expressions/operators/not.dart';
import 'package:jenny/src/structure/line_content.dart';
import 'package:jenny/src/structure/markup_attribute.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/variable_storage.dart';
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
  VariableStorage? localVariables;

  /// The index of the next token to parse.
  int position;

  void parseMain() {
    while (position < tokens.length) {
      final token = peekToken();
      if (token == Token.startCommand) {
        final position0 = position;
        final command = parseCommand();
        if (command is! DeclareCommand) {
          position = position0;
          typeError('command <<${command.name}>> is only allowed inside nodes');
        }
      } else if (token == Token.startHeader) {
        break;
      } else if (token == Token.newline) {
        position += 1;
      } else {
        syntaxError('unexpected token: $token'); // coverage:ignore-line
      }
    }
    while (position < tokens.length) {
      if (peekToken() == Token.newline) {
        position += 1;
        continue;
      }
      final header = parseNodeHeader();
      final block = parseNodeBody();
      final name = header.title!;
      project.nodes[name] = Node(
        title: name,
        tags: header.tags,
        content: block,
        variables: localVariables,
      );
      project.variables.setVariable('@$name', 0);
      localVariables = null;
    }
  }

  _NodeHeader parseNodeHeader() {
    String? title;
    final tags = <String, String>{};
    take(Token.startHeader);
    while (peekToken() != Token.endHeader) {
      if (peekToken() == Token.newline) {
        position += 1;
        continue;
      }
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
      position -= 1;
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
    final lines = <DialogueEntry>[];
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
        final position0 = position;
        final command = parseCommand();
        if (command is DeclareCommand) {
          position = position0;
          syntaxError('<<declare>> command cannot be used inside a node');
        }
        lines.add(command);
      } else if (nextToken.isText ||
          nextToken.isPerson ||
          nextToken == Token.startExpression ||
          nextToken == Token.startMarkupTag) {
        lines.add(parseDialogueLine());
      } else if (nextToken == Token.newline) {
        position += 1;
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

  DialogueOption parseOption() {
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
    return DialogueOption(
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

  LineContent parseLineContent() {
    final stringBuilder = StringBuffer();
    final expressions = <InlineExpression>[];
    final attributes = <MarkupAttribute>[];
    final markupStack = <_Markup>[];
    var subIndex = 0;
    while (true) {
      final token = peekToken();
      if (token.isText) {
        subIndex = 0;
        stringBuilder.write(token.content);
        position += 1;
      } else if (token == Token.startExpression) {
        subIndex += 1;
        take(Token.startExpression);
        final expression = parseExpression();
        take(Token.endExpression);
        expressions.add(
          InlineExpression(
            stringBuilder.length,
            expression.isString
                ? expression as StringExpression
                : StringFn(expression),
          ),
        );
      } else if (token == Token.startMarkupTag) {
        take(Token.startMarkupTag);
        final position0 = position;
        final markupTag = parseMarkupTag();
        take(Token.endMarkupTag);
        if (markupTag.closing) {
          if (markupStack.isEmpty) {
            position = position0;
            syntaxError('unexpected closing markup tag');
          }
          // close-all tag
          if (markupTag.name == null) {
            while (markupStack.isNotEmpty) {
              final tag = markupStack.removeLast();
              tag.endTextPosition = stringBuilder.length;
              tag.endSubIndex = subIndex;
              attributes.add(tag.build());
            }
          } else {
            final openTag = markupStack.removeLast();
            if (openTag.name != markupTag.name) {
              position = position0 + 1;
              syntaxError('Expected closing tag for [${openTag.name}]');
            }
            openTag.endTextPosition = stringBuilder.length;
            openTag.endSubIndex = subIndex;
            attributes.add(openTag.build());
          }
        } else {
          markupTag.startTextPosition = stringBuilder.length;
          markupTag.startSubIndex = subIndex;
          // TODO(stpasha): check that the name of the markup tag is known
          if (markupTag.selfClosing) {
            markupTag.endTextPosition = stringBuilder.length;
            markupTag.endSubIndex = subIndex;
            attributes.add(markupTag.build());
          } else {
            markupStack.add(markupTag);
          }
        }
      } else {
        break;
      }
    }
    if (markupStack.isNotEmpty) {
      syntaxError('markup tag [${markupStack.last.name}] was not closed');
    }
    return LineContent(
      stringBuilder.toString(),
      expressions.isEmpty ? null : expressions,
      attributes.isEmpty ? null : attributes,
    );
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

  _Markup parseMarkupTag() {
    final result = _Markup();
    if (peekToken() == Token.closeMarkupTag) {
      position += 1;
      result.closing = true;
      final nextToken = peekToken();
      if (nextToken.isId) {
        result.name = nextToken.content;
        position += 1;
      } else if (nextToken != Token.endMarkupTag) {
        syntaxError('a markup tag name is expected');
      }
    } else {
      final nextToken = peekToken();
      if (nextToken.isId) {
        result.name = nextToken.content;
        position += 1;
      } else {
        syntaxError('a markup tag name is expected');
      }
      while (peekToken().isId) {
        final position0 = position;
        final parameter = peekToken().content;
        position += 1;
        final Expression expression;
        if (peekToken() == Token.operatorAssign) {
          position += 1;
          expression = parseExpression();
        } else {
          expression = constTrue;
        }
        if (result.parameters.containsKey(parameter)) {
          position = position0;
          syntaxError('duplicate parameter $parameter in a markup attribute');
        }
        result.parameters[parameter] = expression;
      }
      final lastToken = peekToken();
      if (lastToken == Token.closeMarkupTag) {
        result.selfClosing = true;
        position += 1;
      }
    }
    return result;
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
    } else if (token == Token.commandDeclare || token == Token.commandLocal) {
      return parseCommandDeclareOrLocal();
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
      final position0 = position;
      final expression = parseExpression();
      take(Token.endExpression);
      if (expression.isString) {
        target = expression as StringExpression;
      } else {
        typeError('target of <<jump>> must be a string expression', position0);
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
    take(Token.startExpression);
    final position0 = position;
    final expression = parseExpression();
    if (!expression.isNumeric) {
      typeError('<<wait>> command expects a numeric argument', position0);
    }
    take(Token.endExpression);
    take(Token.endCommand);
    takeNewline();
    return WaitCommand(expression as NumExpression);
  }

  Command parseCommandSet() {
    take(Token.startCommand);
    take(Token.commandSet);
    take(Token.startExpression);
    final variableToken = peekToken();
    if (!variableToken.isVariable) {
      syntaxError('variable expected');
    }
    final variableName = variableToken.content;
    final VariableStorage variableStorage;
    if (localVariables?.hasVariable(variableName) ?? false) {
      variableStorage = localVariables!;
    } else if (project.variables.hasVariable(variableName)) {
      variableStorage = project.variables;
    } else {
      nameError('variable $variableName has not been declared');
    }
    final variableExpression =
        variableStorage.getVariableAsExpression(variableName);
    position += 1;

    final assignmentToken = peekToken();
    if (!(assignmentToken == Token.operatorAssign ||
        assignmentTokensToOperators.containsKey(assignmentToken))) {
      syntaxError('an assignment operator is expected');
    }
    position += 1;
    final expressionStartPosition = position;
    final expression = parseExpression();
    if (variableExpression.type != expression.type) {
      typeError(
        'variable $variableName of type ${variableExpression.type.name} '
        'cannot be assigned a value of type ${expression.type.name}',
        expressionStartPosition,
      );
    }
    final Expression assignmentExpression;
    if (assignmentToken == Token.operatorAssign) {
      assignmentExpression = expression;
    } else {
      assignmentExpression = makeBinaryOpExpression(
        assignmentTokensToOperators[assignmentToken]!,
        variableExpression,
        expression,
        expressionStartPosition,
        typeError,
      );
    }
    take(Token.endExpression);
    take(Token.endCommand);
    takeNewline();
    return SetCommand(variableName, assignmentExpression, variableStorage);
  }

  Command parseCommandDeclareOrLocal() {
    take(Token.startCommand);
    final isDeclare = peekToken() == Token.commandDeclare;
    final isLocal = peekToken() == Token.commandLocal;
    assert(isDeclare || isLocal);
    position += 1;
    take(Token.startExpression);
    if (isLocal) {
      localVariables ??= VariableStorage();
    }
    final variableToken = peekToken();
    if (!variableToken.isVariable) {
      syntaxError('variable name expected');
    }
    final variableName = variableToken.content;
    if (isLocal && localVariables!.hasVariable(variableName)) {
      nameError('redeclaration of local variable $variableName');
    }
    if (project.variables.hasVariable(variableName)) {
      nameError(
        isLocal
            ? 'variable $variableName shadows a global variable with the '
                'same name'
            : 'variable $variableName has already been declared',
      );
    }
    position += 1;
    late final Expression expression;
    if (peekToken() == Token.asType) {
      if (isLocal) {
        syntaxError('assignment operator is expected');
      }
      take(Token.asType);
      final typeToken = peekToken();
      final typeExpr = typesToDefaultValues[typeToken];
      if (typeExpr == null) {
        syntaxError('a type is expected');
      }
      expression = typeExpr;
      take(typeToken);
    } else if (peekToken() == Token.operatorAssign) {
      take(Token.operatorAssign);
      expression = parseExpression();
      final nextToken = peekToken();
      if (nextToken == Token.asType) {
        take(Token.asType);
        final typeToken = peekToken();
        final typeExpr = typesToDefaultValues[typeToken];
        if (typeExpr == null) {
          syntaxError('a type is expected');
        }
        if (typeExpr.type != expression.type) {
          typeError('the expression evaluates to ${expression.type.name} type');
        }
        take(typeToken);
      }
    } else {
      syntaxError('expected `= value` or `as Type`');
    }
    take(Token.endExpression);
    take(Token.endCommand);
    takeNewline();
    if (isLocal) {
      final dynamic initialValue = typesToDefaultValues.values
          .where((Expression v) => v.type == expression.type)
          .first
          .value;
      localVariables!.setVariable(variableName, initialValue);
      return LocalCommand(variableName, expression, localVariables!);
    } else {
      project.variables.setVariable(variableName, expression.value);
      return const DeclareCommand();
    }
  }

  Command parseUserDefinedCommand() {
    take(Token.startCommand);
    final commandToken = peekToken();
    position += 1;
    assert(commandToken.isCommand);
    final commandName = commandToken.content;
    if (!project.commands.hasCommand(commandName)) {
      position -= 1;
      nameError('Unknown user-defined command <<$commandName>>');
    }
    final arguments = parseLineContent();
    take(Token.endCommand);
    takeNewline();
    return UserDefinedCommand(commandName, arguments);
  }

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
    if (lhs == constVoid) {
      return lhs;
    }
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
      result = makeBinaryOpExpression(op, result, rhs, position0, typeError);
    }
    return result;
  }

  Expression parsePrimary() {
    final token = peekToken();
    position += 1;
    if (token == Token.startParenthesis) {
      final expression = parseExpression();
      take(Token.endParenthesis, 'missing closing ")"');
      return expression;
    } else if (token == Token.operatorMinus) {
      final expression = parsePrimary();
      if (expression is NumLiteral) {
        return NumLiteral(-expression.value);
      } else if (expression.isNumeric) {
        return Negate(expression as NumExpression);
      } else {
        typeError('unary minus can only be applied to numbers', position - 1);
      }
    } else if (token.isNumber) {
      return NumLiteral(num.parse(token.content));
    } else if (token.isString) {
      return StringLiteral(token.content);
    } else if (token == Token.constTrue || token == Token.constFalse) {
      return BoolLiteral(token == Token.constTrue);
    } else if (token.isVariable) {
      final name = token.content;
      if (localVariables?.hasVariable(name) ?? false) {
        return localVariables!.getVariableAsExpression(name);
      } else if (project.variables.hasVariable(name)) {
        return project.variables.getVariableAsExpression(name);
      } else {
        nameError('variable $name is not defined', position - 1);
      }
    } else if (token.isId) {
      final name = token.content;
      final builder =
          builtinFunctions[name] ?? project.functions.builderForFunction(name);
      if (builder == null) {
        nameError('unknown function name $name', position - 1);
      }
      take(Token.startParenthesis, 'an opening parenthesis "(" is expected');
      final arguments = parseFunctionArguments();
      final functionExpr = builder(arguments, project, typeError);
      take(Token.endParenthesis, 'missing closing ")"');
      return functionExpr;
    } else if (token == Token.operatorNot) {
      final position0 = position;
      final lhs = parsePrimary();
      final arg = _parseExpressionImpl(lhs, precedences[Token.operatorNot]!);
      if (!arg.isBoolean) {
        typeError('operator `not` can only be applied to booleans', position0);
      }
      return Not(arg as BoolExpression);
    }
    position -= 1;
    return constVoid;
  }

  List<FunctionArgument> parseFunctionArguments() {
    final out = <FunctionArgument>[];
    while (true) {
      final position0 = position;
      final expression = parseExpression();
      if (expression == constVoid) {
        break;
      }
      out.add(FunctionArgument(expression, position0));
      final nextToken = peekToken();
      if (nextToken == Token.comma) {
        position += 1;
      } else if (nextToken == Token.endParenthesis) {
        break;
      } else {
        syntaxError('unexpected token');
      }
    }
    return out;
  }

  static final Map<Token, Expression> typesToDefaultValues = {
    Token.typeBool: constFalse,
    Token.typeNumber: constZero,
    Token.typeString: constEmptyString,
  };

  late Map<Token, Token> assignmentTokensToOperators = {
    Token.operatorDivideAssign: Token.operatorDivide,
    Token.operatorMinusAssign: Token.operatorMinus,
    Token.operatorModuloAssign: Token.operatorModulo,
    Token.operatorMultiplyAssign: Token.operatorMultiply,
    Token.operatorPlusAssign: Token.operatorPlus,
  };

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
  bool takeNewline() {
    if (position >= tokens.length) {
      return true;
    } else if (tokens[position] == Token.newline) {
      position += 1;
      return true;
    }
    syntaxError('expected end of line');
  }

  bool take(Token token, [String? message]) {
    if (position >= tokens.length) {
      syntaxError('unexpected end of file'); // coverage:ignore-line
    }
    if (tokens[position] == token) {
      position += 1;
      return true;
    }
    return syntaxError(message ?? 'unexpected token');
  }

  bool takeTokenType(TokenType type) {
    if (tokens[position].type == type) {
      position += 1;
      return true;
    }
    return syntaxError('unexpected token');
  }

  Never nameError(String message, [int? position]) =>
      _error(message, position, NameError.new);

  Never syntaxError(String message, [int? position]) =>
      _error(message, position, SyntaxError.new);

  Never typeError(String message, [int? position]) =>
      _error(message, position, TypeError.new);

  Never _error(
    String message,
    int? position,
    Exception Function(String) errorConstructor,
  ) {
    final errorPosition = position ?? this.position;
    final newTokens = tokenize(text, addErrorTokenAtIndex: errorPosition);
    final errorToken = newTokens[errorPosition];
    final location = errorToken.content;
    throw errorConstructor('$message\n$location\n');
  }
}

typedef FunctionBuilder = Expression Function(
  List<FunctionArgument>,
  YarnProject,
  ErrorFn,
);

class _NodeHeader {
  _NodeHeader(this.title, this.tags);
  String? title;
  Map<String, String>? tags;
}

class _Markup {
  bool closing = false;
  bool selfClosing = false;
  String? name;
  int? startTextPosition;
  int? endTextPosition;
  int? startSubIndex;
  int? endSubIndex;
  Map<String, Expression> parameters = {};

  MarkupAttribute build() {
    assert(!closing);
    return MarkupAttribute(
      name!,
      startTextPosition!,
      endTextPosition!,
      startSubIndex!,
      endSubIndex!,
      parameters.isEmpty ? null : parameters,
    );
  }
}
