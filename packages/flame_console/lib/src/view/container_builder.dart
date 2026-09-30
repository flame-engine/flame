import 'package:flutter/widgets.dart';

Widget defaultContainerBuilder(BuildContext context, Widget child) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xCC000000),
      border: Border.all(color: const Color(0xFFFFFFFF)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    ),
  );
}
