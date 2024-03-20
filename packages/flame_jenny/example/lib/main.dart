import 'package:dashbook/dashbook.dart';
import 'package:flutter/widgets.dart';
import 'package:jenny_example/stories/advanced_jenny.dart';
import 'package:jenny_example/stories/simple_jenny.dart';

void main() {
  runAsDashbook();
}

void runAsDashbook() {
  final dashbook = Dashbook(
    title: 'Jenny Examples',
  );

  addJennySimpleExample(dashbook);
  addJennyAdvancedExample(dashbook);

  runApp(dashbook);
}
