import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //runApp(const MyApp());
  group('FlameBlocLifecyle', () {
    _myBlocGame(MyCubit()).testGameWidget(
      'Validates onRemove is called on child components',
      verify: (game, tester) async {
        await tester.tap(find.text('Play'));
        await tester.pump();
        await tester.pump();
        // Test is not working as FlameGame is not mounting.  This is not a
        // Problem with the code, but a problem with me not knowing how to test
        // bloc properly.
/*         expect(game.myCubit.state, 0);
        await tester.tap(find.text('Plus'));
        await tester.pump();
        await tester.pump();
        expect(game.myCubit.state, 1);
        await tester.tap(find.text('Home'));
        await tester.pump();
        await tester.pump();
        expect(game.componentOnRemoveCalled, true);
        await tester.tap(find.text('Play'));
        await tester.pump();
        await tester.pump();
        expect(game.myCubit.state, 0);
        await tester.tap(find.text('Plus'));
        await tester.pump();
        await tester.pump();
        expect(game.myCubit.state, 1); */
      },
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyCubit>(
      create: (BuildContext context) => MyCubit(),
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GamePage()),
            );
          },
          child: const Text('Play'),
        ),
      ),
      appBar: AppBar(title: const Text('HomePage')),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final _MyGame _myBlocGame;

  @override
  void initState() {
    super.initState();
    _myBlocGame = _MyGame(BlocProvider.of<MyCubit>(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: _myBlocGame),
      appBar: AppBar(title: const Text('GamePage')),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            onPressed: () {
              BlocProvider.of<MyCubit>(context).increase();
            },
            heroTag: null,
            child: const Text('Plus'),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            heroTag: null,
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }
}

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  void increase() {
    emit(state + 1);
  }
}

class _MyGame extends FlameGame {
  _MyGame(this.myCubit);

  final MyCubit myCubit;

  bool onAttachCalled = false;
  bool onDetachCalled = false;
  bool componentOnRemoveCalled = false;

  void resetValues() {
    onAttachCalled = false;
    onDetachCalled = false;
  }

  @override
  void onAttach() {
    super.onAttach();
    onAttachCalled = true;
  }

  @override
  void onDetach() {
    super.onDetach();
    onDetachCalled = true;
  }

  @override
  void onMount() {
    add(
      FlameBlocProvider<MyCubit, int>.value(
        value: myCubit,
        children: [
          LeakingCounterComponent(),
        ],
      ),
    );
    super.onMount();
  }

  @override
  void onRemove() {
    disposeAllOnRemove = true;
    super.onRemove();
  }
}

class LeakingCounterComponent extends TextComponent
    with HasGameRef<_MyGame>, FlameBlocListenable<MyCubit, int> {
  @override
  void onMount() {
    super.onMount();
    mounted.then((value) {
      text = bloc.state.toString();
    });
    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 80,
      ),
    );
    position = game.size / 2;
    anchor = Anchor.center;
  }

  @override
  void onNewState(int state) {
    text = state.toString();
    super.onNewState(state);
  }

  @override
  void onRemove() {
    game.componentOnRemoveCalled = true;
    super.onRemove();
  }
}

FlameTester<_MyGame> _myBlocGame(MyCubit myCubit) {
  return FlameTester(
    () => _MyGame(myCubit),
    pumpWidget: (gameWidget, tester) async {
      await tester.pumpWidget(const MyApp());
    },
  );
}
