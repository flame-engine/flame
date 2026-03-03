import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class RiveExampleGame extends FlameGame with TapCallbacks {
  ViewModelInstanceNumber? coinInput;
  ViewModelInstanceNumber? gemInput;

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
        final vmi = viewModel.createDefaultInstance();
        if (vmi != null) {
          stateMachine.bindViewModelInstance(vmi);
          coinInput = vmi.viewModel('Coin')?.number('Item_Value');
          gemInput = vmi.viewModel('Gem')?.number('Item_Value');
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
    if (coinInput != null) {
      coinInput!.value = (coinInput!.value + 10).clamp(0, 1000);
    }
    if (gemInput != null) {
      gemInput!.value = (gemInput!.value + 1).clamp(0, 1000);
    }
  }
}
