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
    final stateMachine = artboard.defaultStateMachine();

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

class RewardsComponent extends RiveComponent with TapCallbacks {
  RewardsComponent(Artboard artboard, StateMachine? stateMachine)
    : super(
        artboard: artboard,
        stateMachine: stateMachine,
      );

  ViewModelInstanceNumber? _coinInput;
  ViewModelInstanceNumber? _gemInput;
  ViewModelInstanceNumber? _livesInput;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onLoad() {
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
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Top half increments coins, bottom half increments gems
    // Right side decrements lives
    if (event.localPosition.x > size.x / 2) {
      if (_livesInput != null) {
        _livesInput!.value = (_livesInput!.value - 10) % 101;
      }
    } else if (event.localPosition.y < size.y / 2) {
      if (_coinInput != null) {
        _coinInput!.value = (_coinInput!.value + 10) % 1001;
      }
    } else {
      if (_gemInput != null) {
        _gemInput!.value = (_gemInput!.value + 1) % 1001;
      }
    }
  }
}
