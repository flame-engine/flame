import 'dart:html';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'chapter1/main.dart' as chapter1;
import 'chapter2/main.dart' as chapter2;

void main() {
  print('line1');
  var step = window.location.search ?? '';
  if (step.startsWith('?')) {
    step = step.substring(1);
  }
  print('line2, step=$step');
  late final Game game;
  switch (step) {
    case 'step1':
      game = chapter1.MyGame();
      break;
    case 'step2':
      game = chapter2.MyGame();
      break;
    default:
      print('line3');
      runApp(
        Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Invalid page name: [$step]'),
        ),
      );
      return;
  }
  print('line4');
  runApp(GameWidget(game: game));
}

// final routes = _RouteMap()
//   ..add('step1', (builder) => GameWidget(game: ch1.MyGame()))
//   ..add('step2', (builder) => GameWidget(game: ch2.MyGame()));//
// typedef WidgetBuilder = Widget Function(BuildContext);
//
// class _RouteMap {
//   final Map<String, WidgetBuilder> _routes = {};
//
//   bool hasRoute(String route) => _routes.containsKey(route);
//
//   WidgetBuilder getRoute(String name) => _routes[name]!;
//
//   void add(String name, WidgetBuilder builder) {
//     _routes[name] = builder;
//   }
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp(this.routes, {Key? key}) : super(key: key);
//   final _RouteMap routes;
//
//   @override
//   State<StatefulWidget> createState() => _MyState();
// }
//
// class _MyState extends State<MyApp> {
//   String? _stageName;
//
//   @override
//   void initState() {
//     super.initState();
//     window.parent?.addEventListener('message', (event) {
//       final dynamic data = (event as MessageEvent).data;
//       print('Received message:');
//       print(data);
//       setState(() {
//         _stageName = data as String;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_stageName != null && widget.routes.hasRoute(_stageName!)) {
//       return widget.routes.getRoute(_stageName!)(context);
//     }
//     if (_stageName != null) {
//       print('Cannot find route with name $_stageName');
//     }
//     return Container();
//   }
// }
