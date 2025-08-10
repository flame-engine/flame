import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'step2/main.dart' as step2;
import 'step3/main.dart' as step3;
import 'step4/main.dart' as step4;
import 'step5/main.dart' as step5;

void main() {
  var page = web.window.location.search;
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  return switch (page) {
    'step2' => step2.main(),
    'step3' => step3.main(),
    'step4' => step4.main(),
    'step5' => step5.main(),
    _ => runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Error=> unknown page name "$page"'),
      ),
    ),
  };
}
