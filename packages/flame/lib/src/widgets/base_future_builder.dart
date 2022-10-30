import 'dart:async';

import 'package:flutter/material.dart';

class BaseFutureBuilder<T> extends StatelessWidget {
  final FutureOr<T> future;
  final Widget Function(BuildContext, T) builder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? loadingBuilder;

  const BaseFutureBuilder({
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (future is Future<T>) {
      return FutureBuilder<T>(
        future: future as Future<T>,
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
            case ConnectionState.active:
              return loadingBuilder?.call(context) ?? const SizedBox();
            case ConnectionState.done:
              if (snapshot.hasData) {
                return builder(context, snapshot.data!);
              }
              if (snapshot.hasError) {
                return errorBuilder?.call(context) ?? const SizedBox();
              }
              return loadingBuilder?.call(context) ?? const SizedBox();
          }
        },
      );
    }

    return builder(context, future as T);
  }
}
