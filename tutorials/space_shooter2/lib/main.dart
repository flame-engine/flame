import 'dart:html';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'chapter1/main.dart' as ch1;
import 'chapter2/main.dart' as ch2;

void main() {
  final step = window.location.search;
  late final Game game;
  switch (step) {
    case 'step1':
      game = ch1.MyGame();
      break;
    case 'step2':
      game = ch2.MyGame();
      break;
    default:
      runApp(Text('Invalid page name: $step'));
      return;
  }
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
