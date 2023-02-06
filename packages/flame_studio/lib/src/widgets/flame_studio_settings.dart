import 'package:flutter/widgets.dart';

class FlameStudioSettings extends StatefulWidget {
  const FlameStudioSettings({
    required this.child,
    super.key,
  });

  static _FlameStudioSettingsWidget of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_FlameStudioSettingsWidget>();
    assert(result != null, 'No Settings widget among the ancestors');
    return result!;
  }

  final Widget child;

  @override
  State<StatefulWidget> createState() => _FlameStudioSettingsState();
}

class _FlameStudioSettingsState extends State<FlameStudioSettings> {
  double toolbarHeight = 25.0;
  double leftPanelWidth = 250.0;
  double minLeftPanelWidth = 200.0;
  double maxLeftPanelWidth = 500.0;

  @override
  Widget build(BuildContext context) {
    return _FlameStudioSettingsWidget(this, widget.child);
  }
}

// ignore_for_file: invalid_use_of_protected_member
class _FlameStudioSettingsWidget extends InheritedWidget {
  const _FlameStudioSettingsWidget(this._state, Widget child)
      : super(child: child);

  final _FlameStudioSettingsState _state;

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

  @override
  bool updateShouldNotify(_FlameStudioSettingsWidget oldWidget) => true;
}
