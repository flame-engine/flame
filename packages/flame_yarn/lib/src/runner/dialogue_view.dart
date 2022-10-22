import 'dart:async';

import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/option.dart';
import 'package:meta/meta.dart';

class DialogueView {
  const DialogueView();

  /// Called before the start of a new dialogue, i.e. before any lines, options,
  /// or commands are delivered.
  ///
  /// This method is a good place to prepare the game's UI, such as fading in/
  /// animating dialogue panels, or loading resources. If this method returns a
  /// future, then the dialogue will only start running after the future
  /// completes.
  FutureOr<void> onDialogueStart() {}

  /// Called when the dialogue enters a new [node].
  ///
  /// This will be called immediately after the [onDialogueStart], and then
  /// possibly several times more over the course of the dialogue if it visits
  /// multiple nodes.
  ///
  /// If this method returns a future, then the dialogue runner will wait for it
  /// to complete before proceeding.
  FutureOr<void> onNodeStart(Node node) {}

  /// Called when the next dialogue [line] is ready to be presented to the user.
  ///
  /// The dialogue view may decide to present the [line] to the user in whatever
  /// way it wants, or not to present it at all. If this method returns a
  /// future, then the dialogue runner will wait for that future to complete
  /// before advancing to the next line. If multiple [DialogueView]s return
  /// such futures, then the dialogue runner will wait for all of them to
  /// complete before proceeding.
  FutureOr<void> onLineStart(DialogueLine line) {}

  /// Called when the user requests that the presentation of the [line] to be
  /// accelerated.
  ///
  /// For example, if the dialogue view normally reveals the text of the line
  /// gradually (e.g. with a "typewriter" effect), then in response to this
  /// method it should try to reveal the text immediately.
  ///
  /// This method supersedes the [onLineStart]:
  /// 1) it is only called if the future from [onLineStart] is pending;
  /// 2) after this method call the future from [onLineStart] is discarded, and
  ///    the line is considered done presenting when the future from this method
  ///    completes.
  ///
  /// This method is invoked by the dialogue runner only in response to an
  /// external request. Thus, if your game does not invoke the "line rush"
  /// functionality, then this method doesn't have to be implemented.
  FutureOr<void> onLineRush(DialogueLine line) {}

  // ???
  // FutureOr<void> onLineCancel(DialogueLine line) {}

  /// Called when the [line] has finished presenting in all dialog views.
  ///
  /// Some dialog views may need to clear their display when this event happens,
  /// or make some other preparations to receive the next dialogue line. If this
  /// method returns a future, that future will be awaited before proceeding to
  /// the next line in the dialogue.
  FutureOr<void> onLineFinish(DialogueLine line) {}

  /// Called when the dialogue arrives at an option set, and the player must now
  /// make a choice on how to proceed. If a dialogue view presents this choice
  /// to the player and allows them to make a selection, then it must return a
  /// future that completes when the choice is made. If the dialogue view does
  /// not display menu choice, then it should return a future that never
  /// completes (which is the default implementation).
  ///
  /// The dialogue runner will assume the choice has been made whenever any of
  /// the dialogue views will have completed their futures. If none of the
  /// dialogue views are capable of making a choice, then the dialogue will get
  /// stuck.
  ///
  /// The future returned by this method should deliver an integer value of the
  /// index of the option that was selected. This index must not exceed the
  /// length of the [options] list, and the indicated option must not be marked
  /// as "unavailable". If these conditions are violated, an exception will be
  /// raised.
  Future<int> onChoiceStart(List<Option> options) => never;

  /// Called when the choice has been made, and the [option] was selected.
  ///
  /// If this method returns a future, the dialogue runner will wait for that
  /// future to complete before proceeding with the dialogue.
  FutureOr<void> onChoiceFinish(Option option) {}

  /// Called when the dialogue has ended.
  ///
  /// This method can be used to clean up any of the dialogue UI. The returned
  /// future will be awaited before the dialogue runner considers its job
  /// finished.
  FutureOr<void> onDialogueFinish() {}

  /// A future that never completes.
  @internal
  static Future<Never> never = Completer<Never>().future;
}
