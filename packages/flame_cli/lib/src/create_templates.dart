/// A template that `flame create` writes on top of the project that
/// `flutter create` generated.
///
/// The [files] are relative to the project directory, and `{{name}}` in
/// their contents is replaced with the project name.
class CreateTemplate {
  const CreateTemplate({
    required this.name,
    required this.description,
    required this.files,
  });

  final String name;
  final String description;
  final Map<String, String> files;

  /// Whether the template comes with tests, and thus needs `flame_test`.
  bool get hasTests => files.keys.any((path) => path.startsWith('test/'));

  /// The template with the given [name], or null.
  static CreateTemplate? byName(String name) {
    return all.where((template) => template.name == name).firstOrNull;
  }

  static const all = [simple, basics, example];

  /// The emptiest possible game, for starting from scratch.
  static const simple = CreateTemplate(
    name: 'simple',
    description:
        'The emptiest possible Flame game, just the bare minimum to get you '
        'up and running.',
    files: {
      'lib/main.dart': '''
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
}
''',
    },
  );

  /// The structure that most games start from: a world with a component that
  /// reacts to input, and a test for it.
  static const basics = CreateTemplate(
    name: 'basics',
    description:
        'The basic structure that most games start from, a world with a '
        'component that reacts to taps, and a test for it.',
    files: {
      'lib/main.dart': '''
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  late final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await world.add(player = Player());
  }
}

/// A square that starts moving in a random direction when it is tapped.
class Player extends RectangleComponent with TapCallbacks {
  Player()
    : super(
        size: Vector2.all(64),
        anchor: Anchor.center,
        paint: BasicPalette.white.paint(),
      );

  static final _random = Random();

  final Vector2 velocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onTapDown(TapDownEvent event) {
    velocity.setValues(
      _random.nextDouble() * 200 - 100,
      _random.nextDouble() * 200 - 100,
    );
  }
}
''',
      'test/player_test.dart': '''
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name}}/main.dart';

void main() {
  final game = FlameTester(MyGame.new);

  game.testGameWidget(
    'the player starts moving when it is tapped',
    verify: (game, tester) async {
      expect(game.player.velocity, Vector2.zero());

      await tester.tapAt(game.size.toOffset() / 2);
      await tester.pump(const Duration(seconds: 1));

      expect(game.player.velocity, isNot(Vector2.zero()));
    },
  );
}
''',
    },
  );

  /// A complete small game that shows how the most important pieces fit
  /// together.
  static const example = CreateTemplate(
    name: 'example',
    description:
        'A complete small game with a world, a camera, keyboard and tap '
        'input, a score and tests, to show how the pieces fit together.',
    files: {
      'lib/main.dart': '''
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:{{name}}/my_game.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: MyGame.new));
}
''',
      'lib/my_game.dart': r'''
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:{{name}}/player.dart';
import 'package:{{name}}/star.dart';

/// The game: a world with a player that is steered with the arrow keys or
/// by tapping, and stars to collect.
class MyGame extends FlameGame<MyWorld>
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  MyGame() : super(world: MyWorld());

  int score = 0;

  late final TextComponent scoreText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scoreText = TextComponent(text: 'Score: 0', position: Vector2.all(16));
    await camera.viewport.add(scoreText);
  }

  void collectStar() {
    score++;
    scoreText.text = 'Score: $score';
    world.spawnStar();
  }
}

class MyWorld extends World with TapCallbacks {
  static final _random = Random();

  late final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(player = Player());
    spawnStar();
  }

  void spawnStar() {
    add(
      Star(
        position: Vector2(
          _random.nextDouble() * 400 - 200,
          _random.nextDouble() * 400 - 200,
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.target = event.localPosition;
  }
}

/// Keeps the game logic testable by grouping the shared drawing helpers.
abstract final class Palette {
  static final player = BasicPalette.white.paint();
  static final star = BasicPalette.yellow.paint();
}

/// The keys that steer the player, mapped to a direction.
final directionKeys = {
  LogicalKeyboardKey.arrowUp: Vector2(0, -1),
  LogicalKeyboardKey.arrowDown: Vector2(0, 1),
  LogicalKeyboardKey.arrowLeft: Vector2(-1, 0),
  LogicalKeyboardKey.arrowRight: Vector2(1, 0),
};
''',
      'lib/player.dart': '''
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:{{name}}/my_game.dart';
import 'package:{{name}}/star.dart';

/// The square that the player steers around to collect stars.
class Player extends RectangleComponent
    with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks {
  Player()
    : super(
        size: Vector2.all(48),
        anchor: Anchor.center,
        paint: Palette.player,
      );

  static const speed = 200.0;

  final Vector2 _direction = Vector2.zero();
  Vector2? _target;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(RectangleHitbox());
  }

  /// Makes the player move towards [target] until it arrives, or until a
  /// key is pressed.
  set target(Vector2 target) {
    _target = target.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final target = _target;
    if (target != null) {
      final toTarget = target - position;
      if (toTarget.length <= speed * dt) {
        position.setFrom(target);
        _target = null;
      } else {
        position += toTarget.normalized() * speed * dt;
      }
    } else if (!_direction.isZero()) {
      position += _direction.normalized() * speed * dt;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _direction.setZero();
    for (final entry in directionKeys.entries) {
      if (keysPressed.contains(entry.key)) {
        _direction.add(entry.value);
      }
    }
    if (!_direction.isZero()) {
      _target = null;
    }
    return false;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Star) {
      other.removeFromParent();
      game.collectStar();
    }
  }
}
''',
      'lib/star.dart': '''
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:{{name}}/my_game.dart';

/// A star that the player collects by touching it.
class Star extends CircleComponent {
  Star({required super.position})
    : super(radius: 12, anchor: Anchor.center, paint: Palette.star);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());
  }
}
''',
      'test/my_game_test.dart': '''
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name}}/my_game.dart';
import 'package:{{name}}/star.dart';

void main() {
  group('MyGame', () {
    testWithGame('starts with a player and a star', MyGame.new, (game) async {
      await game.ready();

      expect(game.world.children.whereType<Star>(), hasLength(1));
      expect(game.world.player.position, Vector2.zero());
      expect(game.score, 0);
    });

    testWithGame(
      'collecting a star raises the score and spawns a new one',
      MyGame.new,
      (game) async {
        await game.ready();
        final star = game.world.children.whereType<Star>().single;
        game.world.player.position.setFrom(star.position + Vector2(30, 0));
        game.update(0);
        await game.ready();

        expect(game.score, 1);
        expect(game.scoreText.text, 'Score: 1');
        expect(game.world.children.whereType<Star>(), hasLength(1));
        expect(game.world.children.whereType<Star>().single, isNot(star));
      },
    );

    testWithGame('the arrow keys move the player', MyGame.new, (game) async {
      await game.ready();
      game.world.player.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.arrowRight},
      );
      game.update(1);

      expect(game.world.player.position.x, closeTo(200, 0.001));
      expect(game.world.player.position.y, 0);
    });

    testWithGame('the player moves to its target', MyGame.new, (game) async {
      await game.ready();
      game.world.player.target = Vector2(100, 0);
      game.update(10);

      expect(game.world.player.position, Vector2(100, 0));
    });
  });
}
''',
    },
  );
}
