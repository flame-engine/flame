import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class FlameStudioSettings extends StatefulWidget {
  const FlameStudioSettings({
    required this.child,
    required this.gameWidget,
    required this.gameWidgetState,
    super.key,
  });

  static FlameStudioSettingsWidget of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<FlameStudioSettingsWidget>();
    assert(result != null, 'No Settings widget among the ancestors');
    return result!;
  }

  final Widget child;
  final GameWidget? gameWidget;
  final State? gameWidgetState;

  @override
  State<StatefulWidget> createState() => _FlameStudioSettingsState();
}

class _FlameStudioSettingsState extends State<FlameStudioSettings> {
  double toolbarHeight = 28.0;
  double leftPanelWidth = 250.0;
  double minLeftPanelWidth = 200.0;
  double maxLeftPanelWidth = 500.0;

  @override
  Widget build(BuildContext context) {
    return FlameStudioSettingsWidget(this, widget.child);
  }
}

// ignore_for_file: invalid_use_of_protected_member,  for setState() calls
@internal
class FlameStudioSettingsWidget extends InheritedWidget {
  const FlameStudioSettingsWidget(this._state, Widget child, {super.key})
      : super(child: child);

  final _FlameStudioSettingsState _state;

  GameWidget? get gameWidget => _state.widget.gameWidget;
  Game? get game {
    // ignore: avoid_dynamic_calls
    return (_state.widget.gameWidgetState as dynamic)?.currentGame as Game?;
  }

  TextDirection get textDirection => TextDirection.ltr;

  double get toolbarHeight => _state.toolbarHeight;
  set toolbarHeight(double value) => _state.setState(() {
        _state.toolbarHeight = value;
      });

  double get leftPanelWidth => _state.leftPanelWidth;
  set leftPanelWidth(double value) => _state.setState(() {
        _state.leftPanelWidth = value.clamp(
          _state.minLeftPanelWidth,
          _state.maxLeftPanelWidth,
        );
      });

  double get buttonRadius => 5.0;
  Color get buttonColor => const Color(0xFF404040);
  Color get buttonHoverColor => const Color(0xFF606060);
  Color get buttonActiveColor => const Color(0xFFA0A0A0);
  Color get buttonDisabledColor => const Color(0x66404040);
  Color get buttonTextColor => const Color(0xFFffd78d);
  Color get buttonHoverTextColor => const Color(0xffffe95d);
  Color get buttonActiveTextColor => const Color(0xffffffff);
  Color get buttonDisabledTextColor => const Color(0x66ffd78d);

  @override
  bool updateShouldNotify(FlameStudioSettingsWidget oldWidget) => true;
}
