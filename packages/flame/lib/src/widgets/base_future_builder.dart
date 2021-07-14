import 'package:flutter/material.dart';

class BaseFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() futureBuilder;
  final Widget Function(BuildContext, T) builder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? loadingBuilder;

  const BaseFutureBuilder({
    required this.futureBuilder,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _BaseFutureBuilder<T>();
  }
}

class _BaseFutureBuilder<T> extends State<BaseFutureBuilder<T>> {
  late Future<T> future;

  @override
  void initState() {
    super.initState();

    future = widget.futureBuilder();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
          case ConnectionState.active:
            return widget.loadingBuilder?.call(context) ?? Container();
          case ConnectionState.done:
            if (snapshot.hasData) {
              return widget.builder(context, snapshot.data!);
            }
            return widget.loadingBuilder?.call(context) ?? Container();
        }
      },
    );
  }
}
