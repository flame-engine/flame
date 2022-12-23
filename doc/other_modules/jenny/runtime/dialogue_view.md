# DialogueView

The **DialogueView** class is the main mechanism of integrating Jenny with any existing framework,
such as a game engine. This class describes how [line]s and [option]s are presented to the user.

This class is abstract, which means you must create a concrete implementation in order to use the
dialogue system. The concrete `DialogueView` objects will then be passed to a [DialogueRunner],
which will orchestrate the dialogue's progression.


## Properties

**dialogueRunner**: `DialogueRunner?`
: The owner of this DialogueView. This property is non-`null` when the dialogue view is actively
  used by a `DialogueRunner`.

  This property can be used in order to access the parent [YarnProject], or to send signals into the
  sibling `DialogueView`s.


## Methods

These methods that the `DialogueView` can implement in order to respond to the corresponding events.
Each method is optional, with a default implementation that does nothing. This means that you can
only implement those methods that you care about.

Most of the methods return `FutureOr<void>`, which means that the implementations can be either
synchronous or asynchronous. In the latter case, the dialogue runner will wait for the future to
resolve before proceeding (however, the futures from several dialogue views are awaited
simultaneously).

**onDialogueStart**()
: Called at the start of a new dialogue.

  This is a good place to prepare the game's UI, such as fade in or animate dialogue panels, or
  load resources.

**onDialogueFinish**()
: Called when the dialogue is about to finish.

**onNodeStart**(`Node node`)
: Called when the dialogue runner starts executing the [Node]. This will be called right after the
  **onDialogueStart** event, and then each time the dialogue jumps to another node.

  This method is a good place to perform node-specific initialization, for example by querying the
  `node`'s properties or metadata.

**onNodeFinish**(`Node node`)
: Called when the dialogue runner finishes executing the [Node], before **onDialogueFinish**. This
  will also be called every time a node is exited via `<<stop>>` or a `<<jump>>` command (including
  jumps from node to itself).

  This callback can be used to clean up any preparations that were performed in `onNodeStart`.

**onLineStart**(`DialogueLine line`) `-> bool`
: Called when the next dialogue [line] should be presented to the user.

  The DialogueView may decide to present the `line` in whatever way it wants, or to not present
  the line at all. For example, the dialogue view may: augment the line object, render the line at
  a certain place on the screen, render only the character's name, show the portrait of whoever is
  speaking, show the text within a chat bubble, play a voice-over audio file, store the text into
  the player's conversation log, move the camera to show the speaker, etc.

  Some of these methods of delivery can be considered "primary", while others are "auxiliary".
  A "primary" dialogue view should return `true`, while all others `false` (especially if the
  dialogue view ignores the line completely). This is used as a robustness check: if none of the
  dialogue views return `true`, then a `DialogueError` will be thrown because it would mean the
  line was not shown to the user in a meaningful way.

  It is common for non-trivial dialogue views to return a future. After all, if this method were
  to return immediately, the dialogue runner would advance to the next line without any delay,
  and the player wouldn't have time to read the line. A common scenario then is to reveal the line
  gradually, and then wait some time before returning; or, alternatively, return a `Completer`-based
  future that completes based on some user action such as clicking a button or pressing a
  keyboard key.

  Note that this method is supposed to only *show* the line to the player, it should not try to
  hide it at the end -- for that, there is a dedicated method **onLineFinish**.

**onLineSignal**(`DialogueLine line, dynamic signal`)
: Called when the dialogue runner sends the `signal` to all dialogue views.

  The signal will be sent to all views, regardless of whether they have finished running
  their **onLineStart** or not. The interpretation of the signal and the appropriate response
  is up to the dialogue view.

  For example, one possible scenario would be to speed up a typewriter effect and reveal the text
  immediately in response to a "RUSH" signal. Or pause presentation in response to a "PAUSE"
  signal. Or give a warning if the player makes a hostile gesture such as drawing a weapon.

**onLineStop**(`DialogueLine line`)
: Invoked via the [DialogueRunner]'s `stopLine()` method. This is a request to finish presenting
  the line as quickly as possible (though it doesn't have to be immediate).

  Examples when calling this method could be appropriate: the player was hit while talking to
  an NPC; or the user has pressed the "next" button in the dialogue UI.

  This method is invoked on all dialogue views, regardless of whether they finished their
  **onLineStart** call or not. If they haven't, the futures from `onLineStart` will be discarded
  and will no longer be awaited. In addition, the **onLineFinish** will not be called either --
  the line will be considered finished when the future from `onLineStop` completes.

**onLineFinish**(`DialogueLine line`)
: Called when the line has finished presenting in all dialogue views.

  Some dialogue views may need to clear their display when this event happens, or make some other
  preparations to receive the next dialogue line.

**onChoiceStart**(`DialogueChoice choice`) `-> int`
: TODO

**onChoiceFinish**(`DialogueOption option`)
: Called when the choice has been made, and the [option] has been selected.

  The `option` will be the one returned from the **onChoiceStart** method by one of the dialogue
  views.

**onCommand**(`UserDefinedCommand command`)
: Called when executing a user-defined [command].

  This method is invoked immediately after the command itself is executed, but before the result of
  the execution was awaited. Thus, if the command's effect is asynchronous, then it will be send to
  dialogue views and executed "at the same time".

  In cases when the command's effect occurs within the game itself, implementing this method may not
  be necessary. However, if you want to have a command that affects the dialogue views themselves,
  then this method provides a way of doing that.


[DialogueRunner]: dialogue_runner.md
[Node]: node.md
[YarnProject]: yarn_project.md
[command]: user_defined_command.md
[line]: dialogue_line.md
[option]: dialogue_option.md
