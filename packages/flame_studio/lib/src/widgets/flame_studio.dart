import 'package:flame_studio/src/widgets/ui_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class const FlameStudio(final Widget child, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: UiScaffold(gameApp: child),
    );
  }
}
