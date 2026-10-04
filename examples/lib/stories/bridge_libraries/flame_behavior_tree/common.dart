import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

/// The width of the area that all the behavior tree examples play in.
const exampleWidth = 400.0;

/// The base class of the behavior tree examples, which gives them a fixed
/// sized area to play in, with the origin at its top left corner.
abstract class BehaviorTreeGame({required double height}) extends FlameGame {
  this
    : super(
        camera: CameraComponent.withFixedResolution(
          width: exampleWidth,
          height: height,
        )..viewfinder.anchor = Anchor.topLeft,
      );
}

/// An invisible component that reports where it is tapped.
class TapArea({required Vector2 size, required this.onTap})
    extends PositionComponent
    with TapCallbacks {
  this : super(size: size);

  final void Function(Vector2 position) onTap;

  @override
  void onTapDown(TapDownEvent event) => onTap(event.localPosition);
}

final _titleStyle = TextPaint(
  style: const TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontFamily: 'monospace',
  ),
);

final _captionStyle = TextPaint(
  style: const TextStyle(color: Colors.white60, fontSize: 11),
);

/// Creates a text with the style used for the explanations in the examples.
TextComponent caption(
  String text, {
  required Vector2 position,
  Anchor anchor = Anchor.topLeft,
}) {
  return TextComponent(
    text: text,
    position: position,
    anchor: anchor,
    textRenderer: _captionStyle,
  );
}

/// The color that is used to show a [Status] in the examples.
Color statusColor(Status? status) {
  return switch (status) {
    Status.success => Colors.green,
    Status.failure => Colors.red,
    Status.running => Colors.amber,
    null => Colors.grey,
  };
}

/// Where the agent of a [TreeLane] starts and ends its trips.
const laneAgentStart = 20.0;
const laneAgentEnd = exampleWidth - 20;

/// A row that runs one behavior tree and shows what its root node returns.
///
/// The light on the right shows the [Status] that the root node returned most
/// recently. It is held for a moment, so that statuses that only last for a
/// single tick can still be noticed.
///
/// A lane can have an [agent], a small circle on a track, for the nodes that
/// need something to play with.
class TreeLane({
  required this.title,
  required this.explanation,
  required this.build,
  this.hasAgent = false,
}) extends PositionComponent with HasBehaviorTree {
  this : super(size: Vector2(exampleWidth, hasAgent ? 84 : 52));

  /// The code that is shown for this lane.
  final String title;

  /// A short explanation of what the lane shows.
  final String explanation;

  /// Creates the root node of the tree for this lane.
  final Node Function(TreeLane lane) build;

  final bool hasAgent;

  /// The circle on the track, only available if [hasAgent] is true.
  late final CircleComponent agent;

  /// The time, in seconds, since the lane started running.
  double time = 0;

  late final CircleComponent _light;
  late final TextComponent _statusText;
  Status? _shown;
  double _hold = 0;

  @override
  Future<void> onLoad() async {
    _light = CircleComponent(
      radius: 7,
      position: Vector2(width - 20, 14),
      anchor: Anchor.center,
      paint: Paint()..color = statusColor(null),
    );
    _statusText = TextComponent(
      text: 'not started',
      position: Vector2(width - 34, 14),
      anchor: Anchor.centerRight,
      textRenderer: _captionStyle,
    );
    addAll([
      TextComponent(
        text: title,
        position: Vector2(12, 6),
        textRenderer: _titleStyle,
      ),
      caption(explanation, position: Vector2(12, 26)),
      _light,
      _statusText,
      RectangleComponent(
        position: Vector2(0, height - 1),
        size: Vector2(width, 1),
        paint: Paint()..color = Colors.white12,
      ),
    ]);

    if (hasAgent) {
      agent = CircleComponent(
        radius: 8,
        anchor: Anchor.center,
        position: Vector2(laneAgentStart, 62),
        paint: Paint()..color = Colors.cyan,
      );
      addAll([
        RectangleComponent(
          position: Vector2(laneAgentStart, 61),
          size: Vector2(laneAgentEnd - laneAgentStart, 2),
          paint: Paint()..color = Colors.white24,
        ),
        agent,
      ]);
    }

    behaviorTree = BehaviorTree(build(this), owner: this);
  }

  @override
  void update(double dt) {
    time += dt;
    super.update(dt);

    _hold -= dt;
    final status = behaviorTree.lastStatus;
    if (status != _shown && _hold <= 0) {
      _shown = status;
      _hold = 0.3;
      _light.paint.color = statusColor(status);
      _statusText.text = status?.name ?? 'not started';
    }
  }
}

/// Stacks [lanes] below each other, starting at [top].
void addLanes(Component parent, List<TreeLane> lanes, {double top = 0}) {
  var y = top;
  for (final lane in lanes) {
    parent.add(lane..position = Vector2(0, y));
    y += lane.height;
  }
}
