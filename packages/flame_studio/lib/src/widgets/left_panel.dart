import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/panels/hierarchy_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = ref.watch(leftPanelWidthProvider);

    return Directionality(
      textDirection: ref.watch(textDirectionProvider),
      child: MediaQuery.fromView(
        view: View.of(context),
        child: Container(
          constraints: BoxConstraints.tightFor(width: width),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0xA1000000),
                offset: Offset(2, 0),
              ),
            ],
            color: ref.watch(themeProvider).panelColor,
          ),
          child: const HierarchyView(),
        ),
      ),
    );
  }
}

class _WidthNotifier extends StateNotifier<double> {
  _WidthNotifier() : super(250.0);

  static const minWidth = 200.0;
  static const maxWidth = 500.0;

  void setValue(double value) {
    state = value.clamp(minWidth, maxWidth);
  }
}

final leftPanelWidthProvider = StateNotifierProvider<_WidthNotifier, double>(
  (ref) => _WidthNotifier(),
);
