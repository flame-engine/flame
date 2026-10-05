import 'package:behavior_tree/behavior_tree.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// The type of callback used by [PlayEffect] to create its effect.
typedef EffectBuilder = Effect Function(TickContext context);

/// A leaf node that plays an [Effect] and finishes together with it.
///
/// Every time the node starts, [builder] is called to create a fresh effect,
/// which is then added to [target]. The node is [Status.running] while the
/// effect is playing and succeeds as soon as it completes. If the node is
/// aborted before that, for example because a reactive [Sequence] stopped
/// running it, the effect is removed so that it does not keep going on its own.
///
/// ```dart
/// PlayEffect(
///   (context) => ColorEffect(
///     Colors.red,
///     EffectController(duration: 0.3, alternate: true),
///   ),
/// )
/// ```
///
/// The node fails if the effect gets removed before it completed, which
/// happens for example when its target is removed from the game, also if that
/// happens before the effect was mounted.
class PlayEffect(
  /// Creates the effect to play every time the node starts.
  this.builder, {

  /// The component the effect is added to.
  ///
  /// Defaults to the owner of the behavior tree, which has to be a [Component]
  /// in that case.
  this.target,
}) extends Node {
  /// Creates the effect to play every time the node starts.
  final EffectBuilder builder;

  /// The component the effect is added to, or null to use the owner of the
  /// behavior tree.
  final Component? target;

  Effect? _effect;
  var _isComplete = false;

  @override
  void onEnter(TickContext context) {
    final effect = builder(context);
    // The effect tells when it is done, controllers can not be relied on for
    // that before the effect had its first update.
    final onComplete = effect.onComplete;
    effect.onComplete = () {
      _isComplete = true;
      onComplete?.call();
    };
    _isComplete = false;
    _effect = effect;
    (target ?? context.owner<Component>()).add(effect);
  }

  @override
  Status onTick(TickContext context) {
    if (_isComplete) {
      return Status.success;
    }
    // An effect that was removed before it was mounted has no parent but is
    // never marked as removed, and one that is removed while it is mounted is
    // only marked as removed when the removal is processed.
    final effect = _effect!;
    final isGone =
        effect.parent == null || effect.isRemoving || effect.isRemoved;
    return isGone ? Status.failure : Status.running;
  }

  @override
  void onExit(TickContext context, Status status) => _effect = null;

  @override
  void onAbort(TickContext context) {
    _effect?.removeFromParent();
    _effect = null;
  }
}
