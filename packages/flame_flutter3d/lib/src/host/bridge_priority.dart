/// Where in a Flame frame each part of the bridge updates, by name.
///
/// **What every bridged game worked out for itself.** Flame updates a
/// game's children by ascending priority, and the bridge's parts have an
/// order that matters: the phone's stick is read before anything moves, the
/// simulation steps before whatever reads it, the camera follows once the
/// craft have moved, the sound mixes after all of it, and the clock that
/// draws the 3D frame comes last. Each game that used the bridge picked its
/// own numbers for that (the arcade -120 and -110, the example -100) and
/// each component's doc said "give it a priority below the readers". These
/// are those numbers, and the bridge's components take them by default.
///
/// A game's own components sit at Flame's default of 0, between the
/// simulation and the camera, which is where a player's craft wants to be.
///
/// **After Flame's own camera, what reads it.** Flame gives its
/// `CameraComponent` the highest 32-bit priority, so that it follows its
/// target after everything has moved. The clock, the sound and the input's
/// end were placed at 2^20 and so ran before it, and a 3D camera synced
/// from a viewfinder that `camera.follow()` moves trailed it by a frame.
/// They are past it now; Dart's integers, and the web's, go far enough.
abstract final class BridgePriority {
  /// A touch stick's deflection read into the input state: before anything
  /// that reads input.
  static const int input = -(1 << 30);

  /// `KinematicBodyComponent`: a lift moves before whoever stands on it
  /// steps.
  static const int kinematic = -1200;

  /// `ActorSystemComponent`: the actors step before the bodies they push.
  static const int actors = -1100;

  /// `PhysicsStepComponent`: the solver, before anything reads a body.
  static const int physics = -1000;

  /// `ChaseCameraComponent`, and a `CameraSyncComponent` that writes Flame's
  /// viewfinder from the 3D camera: after the craft they follow have moved
  /// this frame, before Flame's camera reads its viewfinder.
  static const int camera = 1000;

  /// Flame's own `CameraComponent`, which follows its target once the
  /// world has moved. Not the bridge's to set; named to order against.
  static const int flameCamera = 0x7fffffff;

  /// A `CameraSyncComponent` that writes the 3D camera from Flame's
  /// viewfinder: after Flame's camera has moved it this frame.
  static const int afterFlameCamera = flameCamera + 1;

  /// A game's sound mixing, after everything that makes one has spoken and
  /// every camera its ears ride on has moved.
  static const int audio = (1 << 32) - 2;

  /// `FlameInputBridge.stepEnd`: the input step closed once everything that
  /// reads it this frame has, just before the frame is drawn.
  static const int inputEnd = (1 << 32) - 1;

  /// `BridgeClock`, which draws the 3D frame: last of all.
  static const int clock = 1 << 32;
}
