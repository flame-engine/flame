import 'package:flutter/material.dart';

class BaseFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? loadingBuilder;

  const BaseFutureBuilder({
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
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
}
