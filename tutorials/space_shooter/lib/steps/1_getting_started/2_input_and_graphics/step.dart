import 'package:flutter/material.dart';
import 'package:tutorials_space_shooter/steps/1_getting_started/2_input_and_graphics/code.dart';
import 'package:tutorials_space_shooter/steps/1_getting_started/2_input_and_graphics/tutorial.dart';
import 'package:tutorials_space_shooter/widgets/step_scaffold.dart';

class InputAndGraphicsStep extends StatelessWidget {
  const InputAndGraphicsStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const StepScaffold(
      tutorial: tutorial,
      game: MyGame(),
    );
  }
}
