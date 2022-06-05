import 'package:flutter/material.dart';
import 'package:tutorials_space_shooter/steps/1_getting_started/1_flame_game/code.dart';
import 'package:tutorials_space_shooter/steps/1_getting_started/1_flame_game/tutorial.dart';
import 'package:tutorials_space_shooter/widgets/step_scaffold.dart';

class RunningFlameStep extends StatelessWidget {
  const RunningFlameStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const StepScaffold(
      tutorial: tutorial,
      game: MyGame(),
    );
  }
}
