import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

// ignore: implicit_dynamic_type
class MockInventoryComponent extends Mock implements BlocComponent {}

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
      'read throws exection when game is not attached yet',
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

        game.prepareComponent(component);

        game.onAttach();

        verify(() => component.subscribe(game)).called(1);
      },
    );

    blocGame.widgetTest(
      'init components with the initial state',
      (game, tester) async {
        final component = InventoryComponent();
        game.add(component);

        expect(component.state, equals(InventoryState.sword));
      },
    );

    blocGame.widgetTest(
      'components listen to changes',
      (game, tester) async {
        final component = InventoryComponent();
        game.add(component);
        game.read<InventoryCubit>().selectBow();

        expect(component.state, equals(InventoryState.sword));
      },
    );
  });
}
