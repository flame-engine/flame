import 'package:flutter/material.dart';
import '../../../widgets/step_scaffold.dart';

import 'code.dart';
import 'tutorial.dart';

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
