import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

class ExampleUseCase extends WidgetbookUseCase {
  ExampleUseCase({
    required super.name,
    required WidgetBuilder builder,
    required this.codeLink,
    required this.info,
  }) : super(builder: _persistent(builder));

  final String codeLink;
  final String info;

  static WidgetBuilder _persistent(WidgetBuilder builder) {
    final key = GlobalKey();
    return (_) => _PersistentExample(key: key, builder: builder);
  }
}

/// Widgetbook rebuilds, and even remounts, the active use case whenever any
/// of its state changes, for example when typing in the search field. This
/// widget only runs the [builder] again when the knobs of the example have
/// changed, so that the games are not restarted for unrelated changes.
class _PersistentExample extends StatefulWidget {
  const _PersistentExample({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  State<_PersistentExample> createState() => _PersistentExampleState();
}

class _PersistentExampleState extends State<_PersistentExample> {
  Widget? _child;
  String? _knobValues;
  Map<String, Knob> _knobs = const {};

  @override
  void reassemble() {
    super.reassemble();
    _child = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = WidgetbookState.of(context);
    final knobValues = state.queryParams['knobs'];
    if (_child == null || knobValues != _knobValues) {
      _child = SizedBox.expand(child: widget.builder(context));
      _knobValues = knobValues;
      _knobs = Map.of(state.knobs);
    } else {
      // The registry is cleared before each build of a use case.
      state.knobs.addAll(_knobs);
    }
    return _child!;
  }
}
