import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class RiveExampleGame extends FlameGame with TapCallbacks {
  ViewModelInstanceNumber? amountInput;

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
          amountInput = vmi.viewModel('Coin')?.number('Item_Value');
        }
      }
    }

    add(
      RiveComponent(
        artboard: artboard,
        stateMachine: stateMachine,
        size: canvasSize,
      ),
    );
  }

  @override
  void onTapDown(_) {
    if (amountInput != null) {
      amountInput!.value = (amountInput!.value + 100) % 1000;
    }
  }
}
