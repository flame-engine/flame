/// What a thing drawn between two steps needs from whatever steps it.
library;

/// Something drawn between its last two steps: told, before each step, to
/// keep where it is as where it was.
abstract interface class StepFollower {
  /// Keeps the present place as the place before the next step.
  void rememberPlace();
}

/// Whatever steps a simulation: how far the frame is past its last step, and
/// who to tell before each one.
///
/// **An interface, because three things step and one of them is the game.**
/// `PhysicsStepComponent` steps rigid bodies and `ActorSystemComponent` steps
/// actors; a game whose simulation steps itself in `HasFixedStep.fixedUpdate`
/// — a genre's own `step`, with the actors and the bodies in it — is the third,
/// and a follower handed only the first two could not draw a body the game
/// moved between its places. It remembered after the game's step had already
/// moved it, and drew the body where it already was.
abstract interface class StepClock {
  /// How far this frame is past the last step, from 0 up to 1.
  double get alpha;

  /// Tells [follower] before each step.
  void follow(StepFollower follower);

  /// Stops telling [follower].
  void unfollow(StepFollower follower);
}
