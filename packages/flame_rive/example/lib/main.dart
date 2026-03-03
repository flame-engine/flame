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
  Future<void> onLoad() async {
    final file = await File.asset(
      'assets/rewards.riv',
      riveFactory: Factory.rive,
    ).then((file) => file!);

    final artboard = await loadArtboard(file);
    final stateMachine = artboard.defaultStateMachine();

    if (stateMachine != null) {
      final viewModel = file.defaultArtboardViewModel(artboard);
      if (viewModel != null) {
        final vmi = viewModel.createDefaultInstance();
        if (vmi != null) {
          stateMachine.bindViewModelInstance(vmi);
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

  ViewModelInstanceNumber? _amountInput;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onLoad() {
    if (stateMachine != null) {
      final vmi = stateMachine!.boundRuntimeViewModelInstance;
      if (vmi != null) {
        _amountInput = vmi.viewModel('Coin')?.number('Item_Value');
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_amountInput != null) {
      _amountInput!.value = (_amountInput!.value + 100) % 1000;
    }
  }
}
