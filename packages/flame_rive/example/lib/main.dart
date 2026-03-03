import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const GameWidget.controlled(gameFactory: RiveExampleGame.new));
}

class RiveExampleGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF444444);

  @override
  Future<void> onLoad() async {
    final file = await File.asset(
      'assets/rewards.riv',
      riveFactory: Factory.flutter,
    ).then((file) => file!);

    final artboard = await loadArtboard(file);
    final stateMachine = artboard.stateMachine('State Machine 1');

    if (stateMachine != null) {
      final viewModel = file.defaultArtboardViewModel(artboard);
      if (viewModel != null) {
        final viewModelInstance = viewModel.createDefaultInstance();
        if (viewModelInstance != null) {
          stateMachine.bindViewModelInstance(viewModelInstance);
        }
      }
    }

    add(RewardsComponent(artboard, stateMachine));
  }
}

class RewardsComponent extends RiveComponent {
  RewardsComponent(Artboard artboard, StateMachine? stateMachine)
    : super(
        artboard: artboard,
        stateMachine: stateMachine,
      );

  ViewModelInstanceNumber? _coinInput;
  ViewModelInstanceNumber? _gemInput;
  ViewModelInstanceNumber? _livesInput;

  late final RewardsArea _livesArea;
  late final RewardsArea _coinArea;
  late final RewardsArea _gemArea;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (isLoaded) {
      _updateAreas();
    }
  }

  void _updateAreas() {
    _livesArea.position = Vector2(size.x / 2, 0);
    _livesArea.size = Vector2(size.x / 2, size.y);

    _coinArea.position = Vector2.zero();
    _coinArea.size = Vector2(size.x / 2, size.y / 2);

    _gemArea.position = Vector2(0, size.y / 2);
    _gemArea.size = Vector2(size.x / 2, size.y / 2);
  }

  @override
  Future<void> onLoad() async {
    if (stateMachine != null) {
      final viewModelInstance = stateMachine!.boundRuntimeViewModelInstance;
      if (viewModelInstance != null) {
        _coinInput = viewModelInstance.viewModel('Coin')?.number('Item_Value');
        _gemInput = viewModelInstance.viewModel('Gem')?.number('Item_Value');
        _livesInput = viewModelInstance
            .viewModel('Energy_Bar')
            ?.number('Lives');
      }
    }

    add(
      _livesArea = RewardsArea(
        onTap: () {
          if (_livesInput != null) {
            _livesInput!.value = (_livesInput!.value - 10) % 101;
          }
        },
      ),
    );
    add(
      _coinArea = RewardsArea(
        onTap: () {
          if (_coinInput != null) {
            _coinInput!.value = (_coinInput!.value + 10) % 1001;
          }
        },
      ),
    );
    add(
      _gemArea = RewardsArea(
        onTap: () {
          if (_gemInput != null) {
            _gemInput!.value = (_gemInput!.value + 1) % 1001;
          }
        },
      ),
    );
    _updateAreas();
  }
}

class RewardsArea extends PositionComponent with TapCallbacks, GestureHitboxes {
  RewardsArea({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void onTapDown(TapDownEvent event) => onTap();
}
