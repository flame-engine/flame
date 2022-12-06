import 'dart:async';
import 'dart:convert';

import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// Verifies that the [input] can be parsed and then executed according to
/// the [testPlan].
///
/// Common indents will be removed from both the [input] and the [testPlan],
/// for convenience.
@isTest
Future<void> testScenario({
  String? testName,
  required String input,
  required String testPlan,
  bool skip = false,
  List<String>? commands,
  YarnProject? yarn,
}) async {
  final yarnProject = yarn ?? YarnProject();
  commands?.forEach(yarnProject.commands.addDialogueCommand);

  Future<void> testBody() async {
    yarnProject.parse(dedent(input));
    final plan = _TestPlan(dedent(testPlan));
    final dialogue = DialogueRunner(
      yarnProject: yarnProject,
      dialogueViews: [plan],
    );
    await dialogue.runNode(plan.startNode);
    assert(
      plan.done,
      '\n'
      'Expected: ${plan.nextEntry}\n'
      'Actual  : END OF DIALOGUE\n',
    );
  }

  if (testName == null) {
    return testBody();
  } else {
    test(testName, testBody, skip: skip);
  }
}

/// Removes common indent from a multi-line [input] string.
String dedent(String input) {
  var commonIndent = 1000;
  final lines = const LineSplitter().convert(input);
  for (final line in lines) {
    final indent = _calculateIndent(line);
    if (indent < line.length && indent < commonIndent) {
      commonIndent = indent;
    }
  }
  if (commonIndent == 0) {
    return input;
  } else {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].length > commonIndent) {
        lines[i] = lines[i].substring(commonIndent);
      }
    }
    return lines.join('\n');
  }
}

int _calculateIndent(String line) {
  for (var i = 0; i < line.length; i++) {
    if (line[i] != ' ') {
      return i;
    }
  }
  return line.length;
}

class _TestPlan extends DialogueView {
  _TestPlan(String input) {
    _parse(input);
  }

  final List<dynamic> _expected = <dynamic>[];
  String startNode = 'Start';
  int _currentIndex = 0;

  bool get done => _currentIndex == _expected.length;
  dynamic get nextEntry => done ? null : _expected[_currentIndex];

  @override
  FutureOr<bool> onLineStart(DialogueLine line) {
    assert(
      !done,
      'Expected: END OF DIALOGUE\n'
      'Actual  : $line',
    );
    assert(
      nextEntry is _Line,
      'Wrong event at test plan index $_currentIndex\n'
      'Expected: "$nextEntry"\n'
      'Actual  : "$line"\n',
    );
    final expected = nextEntry as _Line;
    final text1 = (expected.character == null)
        ? expected.text
        : '${expected.character}: ${expected.text}';
    final text2 = (line.character == null)
        ? line.text
        : '${line.character}: ${line.text}';
    assert(
      text1 == text2,
      'Expected line: "$text1"\n'
      'Actual line  : "$text2"\n',
    );
    _currentIndex++;
    return true;
  }

  @override
  Future<int> onChoiceStart(DialogueChoice choice) async {
    assert(
      !done,
      'Expected: END OF DIALOGUE\n'
      'Actual  : $choice',
    );
    assert(
      nextEntry is _Choice,
      'Wrong event at test plan index $_currentIndex\n'
      'Expected: $nextEntry\n'
      'Actual  : $choice\n',
    );
    final expected = nextEntry as _Choice;
    assert(
      expected.options.length == choice.options.length,
      'Expected: a choice of ${expected.options.length} options\n'
      'Actual  : a choice of ${choice.options.length} options\n',
    );
    for (var i = 0; i < choice.options.length; i++) {
      final option1 = expected.options[i];
      final option2 = choice.options[i];
      final text1 =
          (option1.character == null ? '' : '${option1.character}: ') +
              option1.text +
              (option1.enabled ? '' : ' [disabled]');
      final text2 =
          (option2.character == null ? '' : '${option2.character}: ') +
              option2.text +
              (option2.available ? '' : ' [disabled]');
      assert(
        text1 == text2,
        '\n'
        'Expected (${i + 1}): $text1\n'
        'Actual   (${i + 1}): $text2\n',
      );
      assert(
        option1.enabled == option2.available,
        '\n'
        'Expected option(${i + 1}): $option1; available=${option1.enabled}\n'
        'Actual   option(${i + 1}): $option2; available=${option2.available}\n',
      );
    }
    _currentIndex++;
    return expected.selectionIndex - 1;
  }

  @override
  void onCommand(UserDefinedCommand command) {
    assert(
      !done,
      'Expected: END OF DIALOGUE\n'
      'Actual  : $command',
    );
    assert(
      nextEntry is _Command,
      'Wrong event at test plan index $_currentIndex\n'
      'Expected: "$nextEntry"\n'
      'Actual  : "$command"\n',
    );
    final expected = nextEntry as _Command;
    final text1 = '<<${expected.name} ${expected.content}>>';
    final text2 = '<<${command.name} ${command.argumentString.evaluate()}>>';
    assert(
      text1 == text2,
      'Expected line: "$text1"\n'
      'Actual line  : "$text2"\n',
    );
    _currentIndex++;
  }

  void _parse(String input) {
    final rxEmpty = RegExp(r'^\s*$');
    final rxLine = RegExp(r'^line:\s+((\w+):\s+)?(.*)$');
    final rxOption = RegExp(r'^option:\s+((\w+):\s+)?(.*?)\s*(\[disabled\])?$');
    final rxSelect = RegExp(r'^select:\s+(\d+)$');
    final rxRun = RegExp(r'^run: (.*)$');
    final rxCommand = RegExp(r'command: (\w+)(?:\s+(.*))?$');

    final lines = const LineSplitter().convert(input);
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match0 = rxEmpty.firstMatch(line);
      final match1 = rxLine.firstMatch(line);
      final match2 = rxOption.firstMatch(line);
      final match3 = rxSelect.firstMatch(line);
      final match4 = rxRun.firstMatch(line);
      final match5 = rxCommand.firstMatch(line);
      if (match0 != null) {
        continue;
      } else if (match1 != null) {
        final name = match1.group(2);
        final text = match1.group(3)!;
        _expected.add(_Line(name, text));
      } else if (match2 != null) {
        final name = match2.group(2);
        final text = match2.group(3)!;
        final disabled = match2.group(4) != null;
        _expected.add(_Option(name, text, !disabled));
      } else if (match3 != null) {
        final index = int.parse(match3.group(1)!);
        final options = <_Option>[];
        while (_expected.isNotEmpty && _expected.last is _Option) {
          options.insert(0, _expected.removeLast() as _Option);
        }
        _expected.add(_Choice(options, index));
      } else if (match4 != null) {
        startNode = match4.group(1)!;
      } else if (match5 != null) {
        _expected.add(_Command(match5.group(1)!, match5.group(2) ?? ''));
      } else {
        throw 'Unrecognized test plan line $i: "$line"';
      }
    }
  }
}

class _Line {
  const _Line(this.character, this.text);
  final String? character;
  final String text;

  @override
  String toString() => 'Line($character: $text)';
}

class _Choice {
  const _Choice(this.options, this.selectionIndex);
  final List<_Option> options;
  final int selectionIndex;

  @override
  String toString() => 'Choice($options)';
}

class _Option {
  const _Option(this.character, this.text, this.enabled);
  final String? character;
  final String text;
  final bool enabled;

  @override
  String toString() => 'Option($character: $text [$enabled])';
}

class _Command {
  const _Command(this.name, this.content);
  final String name;
  final String content;
  @override
  String toString() => 'Command($name, "$content")';
}
