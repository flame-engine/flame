import 'package:flutter/material.dart';

Widget defaultCursorBuilder(BuildContext context) {
  return const ColoredBox(
    color: Colors.white,
    child: SizedBox(
      width: 8,
      height: 20,
    ),
  );
}
