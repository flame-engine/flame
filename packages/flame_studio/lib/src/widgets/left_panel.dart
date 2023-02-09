import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = Settings.of(context);
    final width = ref.watch(leftPanelWidthProvider);

    return Container(
      constraints: BoxConstraints.tightFor(width: width),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0xA1000000),
            offset: Offset(2, 0),
          ),
        ],
        color: settings.panelColor,
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

final leftPanelWidthProvider =
    StateNotifierProvider<_WidthNotifier, double>((ref) => _WidthNotifier());
