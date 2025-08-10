import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/line_content.dart';

/// The **DialogueLine** class represents a single line of text within the
/// dialogue [[Line]].
///
/// The `DialogueLine` objects will be delivered to your [DialogueView] with
/// methods `onLineStart()`, `onLineSignal()`, `onLineStop()`, and
/// `onLineFinish()`.
///
/// A dialogue line may contain a [character] (the name of the entity who is
/// speaking), and [tags] -- a list of hashtag tokens that specify some meta
/// information about the line.
///
/// Example of a dialogue line in yarn script:
/// ```yarn
/// Hermione: Holy cricket! You're Harry Potter.  #surprised
/// ```
/// Here the [character] is "Hermione", the [text] of the line is "Holy
/// cricket! You're Harry Potter.", and the [tags] list will contain a single
/// entry "#surprised".
///
/// A dialogue line may also contain inline expressions, which will be
/// re-evaluated every time the line is executed by the dialogue runner:
/// ```yarn
/// Jenny: My favorite color is {$favoriteColor}, what about you?
/// ```
/// After evaluation, the resulting string may be "My favorite color is
/// vantablack, what about you?".
///
/// Lastly, a dialogue line may have markup attributes. These are similar to
/// HTML tags, only they use square brackets:
/// ```yarn
/// Jenny: My [i]favorite[/i] color is [bb color=$color]{$color}[/bb].
/// ```
/// These markup attributes will not be visible in the output (i.e. the
/// resulting text is still "My favorite color is vantablack"), but they can be
/// queried in the [attributes] list, which will specify that there is an
/// attribute `[i]` around the word "favorite", and another attribute `[bb]`
/// with parameter `color` around the word "vantablack".
///
/// Inline expressions cannot contain markup attributes.
class DialogueLine extends DialogueEntry {
  DialogueLine({
    required LineContent content,
    Character? character,
    List<String>? tags,
  }) : _content = content,
       _character = character,
       _tags = tags,
       _value = content.isConst ? content.text : null;

  final Character? _character;
  final List<String>? _tags;
  final LineContent _content;
  String? _value;

  /// The content of this Line.
  LineContent? get content => _content;

  /// The character who is speaking the line. This can be null if the line does
  /// not contain a speaker.
  Character? get character => _character;

  /// The computed text of the line, after substituting all inline expressions,
  /// stripping the markup, and processing the escape sequences.
  ///
  /// This value can only be accessed after the line was [evaluate]d. It may
  /// change upon subsequent re-evaluations of the line (which occur each time
  /// the line goes through a [DialogueRunner]).
  String get text {
    assert(_value != null, 'Line was not evaluated');
    return _value!;
  }

  /// The list of hashtags associated with the line. If there are no hashtags,
  /// the list will be empty.
  ///
  /// Each value in the list will start with the `#` symbol.
  List<String> get tags => _tags ?? const [];

  /// The list of markup spans associated with the line.
  List<MarkupAttribute> get attributes => _content.attributes ?? const [];

  /// True if the line will never change upon subsequent reruns. That is, when
  /// the line does not depend on any dynamic expressions.
  bool get isConst => _content.isConst;

  @override
  Future<void> processInDialogueRunner(DialogueRunner dialogueRunner) {
    evaluate();
    return dialogueRunner.deliverLine(this);
  }

  /// Computes the [text] of the line, substituting the current values of all
  /// inline expressions.
  ///
  /// Normally, you wouldn't need to call this method manually -- the
  /// [DialogueRunner] will take care to do that for you. However, it may be
  /// necessary to call this if you need to access `DialogueLine`s outside of
  /// a dialogue runner.
  void evaluate() {
    _value = _content.evaluate();
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '${character!.name}: ';
    final text = _value ?? '<unevaluated>';
    return 'DialogueLine($prefix$text)';
  }

  @override
  bool operator ==(Object other) =>
      other is DialogueLine &&
      text == other.text &&
      character == other.character;
}
