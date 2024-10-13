import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/toolbar/next_frame_button.dart';
import 'package:flame_studio/src/widgets/toolbar/pause_button.dart';
import 'package:flame_studio/src/widgets/toolbar/start_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toolbarHeightProvider = Provider((ref) => 28.0);

class FlameStudioToolbar extends ConsumerWidget {
  const FlameStudioToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const middleButtons = <Widget>[
      StartButton(),
      PauseButton(),
      NextFrameButton(),
    ];

    final height = ref.watch(toolbarHeightProvider);
    final gap = height * 0.1;

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
        color: ref.watch(themeProvider).toolbarColor,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gap * 2, gap, gap * 10, gap * 2),
            child: Image.asset('logo_flame.png', fit: BoxFit.scaleDown),
          ),
          Expanded(child: Container()),
          for (final button in middleButtons)
            Padding(padding: EdgeInsets.all(gap), child: button),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
