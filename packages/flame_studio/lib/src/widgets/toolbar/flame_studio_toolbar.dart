import 'package:flame_studio/src/core/settings.dart';
import 'package:flame_studio/src/widgets/toolbar/pause_button.dart';
import 'package:flame_studio/src/widgets/toolbar/start_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toolbarHeightProvider = Provider((ref) => 28.0);

class FlameStudioToolbar extends ConsumerWidget {
  const FlameStudioToolbar({super.key});

  /// List of widgets to show on the left side of the toolbar.
  static final List<Widget> left = [];

  /// List of widgets to show in the center of the toolbar.
  static final List<Widget> middle = [
    const StartButton(),
    const PauseButton(),
  ];

  /// List of widgets to show on the right side of the toolbar.
  static final List<Widget> right = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = Settings.of(context);
    final height = ref.watch(toolbarHeightProvider); // settings.toolbarHeight;
    final gap = height * 0.10;

    return Container(
      constraints: BoxConstraints.tightFor(height: height),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 3),
            blurRadius: 7.0,
          ),
          BoxShadow(
            color: Color(0xbf000000),
            offset: Offset(0, 1),
            blurRadius: 2.0,
          ),
        ],
        color: settings.toolbarColor,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gap * 2, gap, gap * 10, gap * 2),
            child: Image.asset('logo_flame.png', fit: BoxFit.scaleDown),
          ),
          for (final button in left) _ButtonWithPadding(button, gap),
          Expanded(child: Container()),
          for (final button in middle) _ButtonWithPadding(button, gap),
          Expanded(child: Container()),
          for (final button in right) _ButtonWithPadding(button, gap),
        ],
      ),
    );
  }
}

class _ButtonWithPadding extends StatelessWidget {
  const _ButtonWithPadding(this.button, this.padding);

  final Widget button;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(padding), child: button);
  }
}
