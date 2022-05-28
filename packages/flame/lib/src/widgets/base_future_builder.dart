import 'dart:async';

import 'package:flutter/material.dart';

class BaseFutureBuilder<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final future = futureBuilder();

    if (future is Future<T>) {
      return FutureBuilder<T>(
        future: future,
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
            case ConnectionState.active:
              return loadingBuilder?.call(context) ?? Container();
            case ConnectionState.done:
              if (snapshot.hasData) {
                return builder(context, snapshot.data!);
              }
              return loadingBuilder?.call(context) ?? Container();
          }
        },
      );
    }

    return builder(context, future);
  }
}
