import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

/// A widget that rebuilds every time the given [notifier] changes.
class const ComponentsNotifierBuilder<T extends Component>({
  required final ComponentsNotifier<T> notifier,
  required final Widget Function(BuildContext, ComponentsNotifier<T>) builder,
  super.key,
}) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ComponentsNotifierBuilderState<T>();
  }
}

class _ComponentsNotifierBuilderState<T extends Component>()
    extends State<ComponentsNotifierBuilder<T>> {
  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(_listener);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_listener);

    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.notifier);
}
