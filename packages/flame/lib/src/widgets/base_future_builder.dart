import 'dart:async';

import 'package:material_ui/material_ui.dart';

class const BaseFutureBuilder<T>({
  required final FutureOr<T> future,
  required final Widget Function(BuildContext, T) builder,
  final WidgetBuilder? loadingBuilder,
  final WidgetBuilder? errorBuilder,
  super.key,
}) extends StatelessWidget {
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
              if (snapshot.hasError) {
                return errorBuilder?.call(context) ?? const SizedBox();
              }
              final data = snapshot.data;
              if (data != null) {
                return builder(context, data);
              }
              return loadingBuilder?.call(context) ?? const SizedBox();
          }
        },
      );
    }

    return builder(context, future as T);
  }
}
