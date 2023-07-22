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
        expect(game.myCubit.state, 0);
        await tester.tap(find.text('Plus'));
        await tester.pump();
        await tester.pump();
        print('Test1 ${game.myCubit.state}');
        await tester.tap(find.text('Home'));
        await tester.pump();
        print('Test2 ${game.myCubit.state}');
        await tester.pump();
        print('Test3 ${game.myCubit.state}');
        await tester.tap(find.text('Play'));
        print('Test4 ${game.myCubit.state}');
        await tester.pump();
        print('Test5 ${game.myCubit.state}');
        await tester.pump();
        print('Test6 ${game.myCubit.state}');
        //expect(game.myCubit.state, 0);
        await tester.tap(find.text('Plus'));
        print('Test7 ${game.myCubit.state}');
        await tester.pump();
        print('Test8 ${game.myCubit.state}');
        await tester.pump();
        print('Test9 ${game.myCubit.state}');

        game.disposeAllOnRemove = true;
        await tester.tap(find.text('Home'));
        await tester.pump();
        print('Test2 ${game.myCubit.state}');
        await tester.pump();
        print('Test3 ${game.myCubit.state}');
        await tester.tap(find.text('Play'));
        print('Test4 ${game.myCubit.state}');
        await tester.pump();
        print('Test5 ${game.myCubit.state}');
        await tester.pump();
        print('Test6 ${game.myCubit.state}');
        //expect(game.myCubit.state, 0);
        await tester.tap(find.text('Plus'));
        print('Test7 ${game.myCubit.state}');
        await tester.pump();
        print('Test8 ${game.myCubit.state}');
        await tester.pump();
        print('Test9 ${game.myCubit.state}');
        //expect(game.myCubit.state, 1);
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
    print('game init called');
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
              print('button pressed');
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
    print('increased');
    emit(state + 1);
    print('state is ${state}');
  }

  void decrease() {
    print('decreased');
    emit(state - 1);
    print('state is ${state}');
  }
}

class _MyGame extends FlameGame {
  _MyGame(this.myCubit);

  final MyCubit myCubit;

  @override
  void onAttach() {
    super.onAttach();
    print('myCubitState ${myCubit.state}');
  }

  @override
  void onDetach() {
    print('myCubitState ${myCubit.state}');
    super.onDetach();
  }

  @override
  void onMount() {
    print('fg mounted ${myCubit.state}');
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
    print('fg onRemove called ${myCubit.state}');
    super.onRemove();
  }
}

class LeakingCounterComponent extends TextComponent
    with HasGameRef<_MyGame>, FlameBlocListenable<MyCubit, int> {
  @override
  void onMount() {
    super.onMount();
    print('lc mounted ${game.myCubit.state}');
  }

  @override
  void onRemove() {
    print('lc onRemove called  ${game.myCubit.state}');
    game.myCubit.decrease();
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
