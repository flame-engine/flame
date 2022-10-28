import 'dart:async';

import 'package:flame_yarn/src/errors.dart';
import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/dialogue_line.dart';
import 'package:flame_yarn/src/structure/node.dart';
import 'package:flame_yarn/src/structure/option.dart';
import 'package:meta/meta.dart';

abstract class DialogueView {
  const DialogueView();

  /// Called before the start of a new dialogue, i.e. before any lines, options,
  /// or commands are delivered.
  ///
  /// This method is a good place to prepare the game's UI, such as fading in/
  /// animating dialogue panels, or loading resources. If this method returns a
  /// future, then the dialogue will start running only after the future
  /// completes.
  FutureOr<void> onDialogueStart() {}

  /// Called when the dialogue enters a new [node].
  ///
  /// This will be called immediately after the [onDialogueStart], and then
  /// possibly several times more over the course of the dialogue if it visits
  /// multiple nodes.
  ///
  /// If this method returns a future, then the dialogue runner will wait for it
  /// to complete before proceeding with the actual dialogue.
  FutureOr<void> onNodeStart(Node node) {}

  /// Called when the next dialogue [line] should be presented to the user.
  ///
  /// The [DialogueView] may decide to present the [line] in whatever way it
  /// wants, or to not present the line at all. For example, the dialogue view
  /// may: augment the line object, render the line at a certain place on the
  /// screen, render only the character's name, show the portrait of whoever is
  /// speaking, show the text within a chat bubble, play a voice-over audio
  /// file, store the text into the player's conversation log, move the camera
  /// to show the speaker, etc.
  ///
  /// Some of these methods of delivery can be considered "primary", while
  /// others are "auxiliary". A "primary" [DialogueView] should return `true`,
  /// while all others `false` (especially if a dialogue view ignores the line
  /// completely). This is used as a robustness check: if none of the dialogue
  /// views return `true`, then a [DialogueError] will be thrown because the
  /// line was not shown to the user in a meaningful way.
  ///
  /// If this method returns a future, then the dialogue runner will wait for
  /// that future to complete before advancing to the next line. If multiple
  /// [DialogueView]s return such futures, then the dialogue runner will wait
  /// for all of them to complete before proceeding.
  ///
  /// Returning a future is quite common for non-trivial [DialogueView]s. After
  /// all, if this method were to return immediately, the dialogue runner would
  /// immediately advance to the next line, and the player wouldn't have time
  /// to read the first one. A common scenario then is to reveal the line
  /// gradually, and then wait some time before returning; or, alternatively,
  /// return a [Completer]-based future that completes based on some user action
  /// such as clicking a button or pressing a keyboard key.
  ///
  /// Note that this method is supposed to *show* the line to the player, so
  /// do not try to hide it at the end -- for that, there is a dedicated method
  /// [onLineFinish].
  ///
  /// Also, given that this method may take a significant amount of time, there
  /// are two additional methods that may attempt to interfere into this
  /// process: [onLineSignal] and [onLineStop].
  FutureOr<bool> onLineStart(DialogueLine line) => false;

  /// Called when the game sends a [signal] to all dialogue views.
  ///
  /// The signal will be sent to all views, regardless of whether they have
  /// finished running [onLineStart] or not. The interpretation of the signal
  /// and the appropriate response is up to the [DialogueView].
  ///
  /// For example, one possible scenario would be to speed up a typewriter
  /// effect and reveal the text immediately in response to the RUSH signal.
  /// Or make some kind of an interjection in response to an OMG event. Or
  /// pause presentation in response to a PAUSE signal. Or give a warning if
  /// the player makes a hostile gesture such as drawing a weapon.
  void onLineSignal(DialogueLine line, dynamic signal) {}

  /// Called when the game demands that the [line] finished presenting as soon
  /// as possible.
  ///
  /// By itself, the dialogue runner will never call this method. However, it
  /// may be invoked as a result of an explicit request by the game (or by one
  /// of the dialogue views). Examples when this could be appropriate: (a) the
  /// player was hit while talking to an NPC -- better stop talking and fight
  /// for your life, (b) the user has pressed a "skip dialogue" button, so we
  /// should stop the current line and proceed to the next one ASAP.
  ///
  /// This method returns a future that will be awaited before continuing to
  /// the next line of the dialogue. At the same time, any future that's still
  /// pending from the [onLineStart] call will be discarded and will no longer
  /// be awaited. The [onLineFinish] method will not be called either.
  FutureOr<void> onLineStop(DialogueLine line) {}

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
  /// length of the [choice] list, and the indicated option must not be marked
  /// as "unavailable". If these conditions are violated, an exception will be
  /// raised.
  Future<int> onChoiceStart(DialogueChoice choice) => never;

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

Me & @spydon had a discussion about the possibility of splitting the flame_yarn package, and it would probably be good to bring that discussion over here.
As Lukas have noted, it is conceivable to split the flame_yarn into 2 parts: one would be the "core" yarn, while flame_yarn would provide only components for integrating the dialogue into the Flame. It appears that making such separation and drawing clean API boundaries between the two packages would be quite feasible to do. The main benefit of making such a split is that it would allow people to integrate yarn into games (or other apps) that do not rely on Flame.
The downsides to such a split depend on whether the core yarn package would reside in the main monorepo alongside the flame_yarn, or would be converted into a completely standalone repository:
1. If yarn lives in the monorepo, then there will be some organizational questions -- like why does it live there? would people be intimidated by this fact? would there be any problem with the Issues or PR queue?
- I personally find these concerns quite weak; plus, exactly the same questions can be asked about the current flame_yarn package, so  in this sense option (1) does not make anything worse compared to the current state.
2. The second option is to push yarn out into its own repo -- and now there are quite a lot of downsides:
- Inability to co-develop features that require changes in both yarn and flame_yarn. "Inability" means it would be really hard to do, especially if it's unclear beforehand what kind of changes are needed in upstream yarn.
- Documentation? We have a great documentation system for flame monorepo, which we worked hard to implement, and which we keep updating all the time. If yarn is pushed outside, then it loses access to that.
- CI tooling, which is also continuously improving.
Overall, it seems to me that option 1 would be net positive compared to status quo, while option 2 is net negative. Thoughts?
