import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the ambient widgets that the studio UI relies on.
///
/// The studio does not run inside of a [WidgetsApp], so that the game can
/// bring its own app. This widget is used to wrap each part of the studio UI
/// (but never the game) with what a [WidgetsApp] would otherwise provide.
class const StudioChrome({required final Widget child, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Directionality(
      textDirection: ref.watch(textDirectionProvider),
      child: MediaQuery.fromView(
        view: View.of(context),
        child: DefaultTextEditingShortcuts(
          child: DefaultTextStyle(
            style: TextStyle(
              color: theme.textColor,
              fontSize: theme.fontSize,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
