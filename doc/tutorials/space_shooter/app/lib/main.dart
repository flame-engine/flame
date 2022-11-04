import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:flutter/widgets.dart';
import 'package:tutorials_space_shooter/step1/main.dart' as step1;
import 'package:tutorials_space_shooter/step2/main.dart' as step2;

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }

  switch (page) {
    case 'step1':
      step1.main();
      break;
    case 'step2':
      step2.main();
      break;

    default:
      runApp(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text('Error: unknown page name "$page"'),
        ),
      );
  }
}
