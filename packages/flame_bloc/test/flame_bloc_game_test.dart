import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

enum InventoryState {
  sword,
  bow,
}

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState.sword);

  void selectBow() {
    emit(InventoryState.bow);
  }

  void selectSword() {
    emit(InventoryState.bow);
  }
}

class MyBlocGame extends FlameBlocGame {}

class InventoryComponent extends Component
    with BlocComponent<InventoryCubit, InventoryState> {}

class MockInventoryComponent extends Component
    with BlocComponent<InventoryCubit, InventoryState> {
  int numSubscribeCalls = 0;

  @override
  void subscribe(FlameBloc game) {
    numSubscribeCalls++;
  }
}

void main() {
  group('FlameBlocGame', () {
    late InventoryCubit cubit;

    setUp(() {
      cubit = InventoryCubit();
    });

    final blocGame = FlameTester<MyBlocGame>(
      () => MyBlocGame(),
      pumpWidget: (gameWidget, tester) async {
        await tester.pumpWidget(
          BlocProvider<InventoryCubit>.value(
            value: cubit,
            child: gameWidget,
          ),
        );
      },
    );

    blocGame.widgetTest(
      'can emit states',
      (game, tester) async {
        game.read<InventoryCubit>().selectBow();

        expect(cubit.state, equals(InventoryState.bow));
      },
    );

    blocGame.test(
      'read throws exception when game is not attached yet',
      (game) {
        expect(() => game.read<InventoryCubit>(), throwsException);
      },
    );

    blocGame.test(
      'adds component to queue when is not attached',
      (game) {
        game.add(InventoryComponent());
        game.update(0);

        expect(game.subscriptionQueue.length, equals(1));
      },
    );

    blocGame.test(
      'runs the queue when game is attached',
      (game) {
        final component = MockInventoryComponent();
        game.add(component);
        game.update(0);
        expect(game.subscriptionQueue.length, 1);
        game.onAttach();

        expect(component.numSubscribeCalls, 1);
      },
    );

    blocGame.widgetTest(
      'init components with the initial state',
      (game, tester) async {
        final component = InventoryComponent();
        game.add(component);
        await game.ready();

        expect(component.state, equals(InventoryState.sword));
      },
    );

    blocGame.widgetTest(
      'Components can be removed',
      (game, tester) async {
        final component = InventoryComponent();
        game.add(component);
        game.update(0);
        expect(game.children.length, 1);

        game.remove(component);
        game.update(0);
        expect(game.children.length, 0);
      },
    );

    blocGame.widgetTest(
      'components listen to changes',
      (game, tester) async {
        final component = InventoryComponent();
        game.add(component);
        await game.ready();
        game.read<InventoryCubit>().selectBow();

        expect(component.state, equals(InventoryState.sword));
      },
    );
  });
}
