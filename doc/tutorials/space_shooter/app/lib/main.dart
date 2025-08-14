import 'package:flutter/widgets.dart';
import 'package:tutorials_space_shooter/step1/main.dart' as step1;
import 'package:tutorials_space_shooter/step2/main.dart' as step2;
import 'package:tutorials_space_shooter/step3/main.dart' as step3;
import 'package:tutorials_space_shooter/step4/main.dart' as step4;
import 'package:tutorials_space_shooter/step5/main.dart' as step5;
import 'package:tutorials_space_shooter/step6/main.dart' as step6;
import 'package:web/web.dart' as web;

void main() {
  var page = web.window.location.search;
  if (page.startsWith('?')) {
    page = page.substring(1);
  }

  return switch (page) {
    'step1' => step1.main(),
    'step2' => step2.main(),
    'step3' => step3.main(),
    'step4' => step4.main(),
    'step5' => step5.main(),
    'step6' => step6.main(),
    _ => runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text('''Error: unknown page. Pass "step{1,6}" as a GET param; 
e.g: ${web.window.location}?step1'''),
      ),
    ),
  };
}
