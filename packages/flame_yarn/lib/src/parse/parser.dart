import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:flame_yarn/src/parse/tokenize.dart';
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
    final parts = <Expression<String>>[];
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
      final position0 = position + 1;
      final commandBuilder = _CommandBuilder();
      parseCommand();
      // if command is not <<if>>, revert to position0 and issue error
      // otherwise, store the command into the [line]
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

  void parseExpression(_ExpressionBuilder<String> expression) {
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
  Expression<String>? content;
  Expression<bool>? condition;
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
    Expression<T> build() => throw 'error';
}
