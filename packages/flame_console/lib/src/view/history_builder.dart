import 'package:flutter/material.dart';

Widget defaultHistoryBuilder(
  BuildContext context,
  ScrollController scrollController,
  Widget child,
) {
  return SingleChildScrollView(
    controller: scrollController,
    child: child,
  );
}
