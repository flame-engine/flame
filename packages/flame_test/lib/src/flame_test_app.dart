import 'package:flutter/widgets.dart';

/// A minimal app to host widgets in tests, built on [WidgetsApp].
///
/// It provides what a game widget usually needs from an app, such as
/// [MediaQuery], [Directionality] and a default text style.
class const FlameTestApp({
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      debugShowCheckedModeBanner: false,
      builder: (_, _) => child,
    );
  }
}
