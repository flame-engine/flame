import 'package:flutter/material.dart';

Widget defaultContainerBuilder(BuildContext context, Widget child) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.8),
      border: Border.all(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    ),
  );
}
