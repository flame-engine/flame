import 'dart:async';

import 'package:flutter/material.dart';

class BaseFutureBuilder<T> extends StatefulWidget {
  final FutureOr<T> Function() futureBuilder;
  final Widget Function(BuildContext, T) builder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? loadingBuilder;

  const BaseFutureBuilder({
    required this.futureBuilder,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<BaseFutureBuilder<T>> createState() => _BaseFutureBuilderState<T>();
}

class _BaseFutureBuilderState<T> extends State<BaseFutureBuilder<T>> {
  late final FutureOr<T> maybeFuture;

  @override
  void initState() {
    maybeFuture = widget.futureBuilder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (maybeFuture is Future<T>) {
      return FutureBuilder<T>(
        future: maybeFuture as Future<T>,
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

    return widget.builder(context, maybeFuture as T);
  }
}
