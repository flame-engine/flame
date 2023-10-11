// import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter/widgets.dart';
import 'step2/main.dart' as step2;
import 'step3/main.dart' as step3;
import 'step4/main.dart' as step4;

void main() {
  // var page = window.location.search ?? '';
  var page = 'step4';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  switch (page) {
    case 'step2':
      step2.main();
      break;

    case 'step3':
      step3.main();
      break;

    case 'step4':
      step4.main();
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
