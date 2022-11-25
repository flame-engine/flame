import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A widget that rebuilds every time the given [notifier] changes.
class ComponentsNotifierBuilder<T extends Component> extends StatefulWidget {
  const ComponentsNotifierBuilder({
    super.key,
    required this.notifier,
    required this.builder,
  });

  final ComponentsNotifier<T> notifier;
  final Widget Function(BuildContext, ComponentsNotifier<T>) builder;

  @override
  State<StatefulWidget> createState() {
    return _ComponentsNotifierBuilderState<T>();
  }
}

class _ComponentsNotifierBuilderState<T extends Component>
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
