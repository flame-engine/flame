import 'package:bloc/bloc.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
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

class MockInventoryComponent extends Mock implements BlocComponent {}

void main() {
  group('FlameBlocGame', () {
    late InventoryCubit cubit;

    setUp(() {
      cubit = InventoryCubit();
    });

    Future<void> _pumpWidget(
      GameWidget<MyBlocGame> gameWidget,
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<InventoryCubit>.value(
          value: cubit,
          child: gameWidget,
        ),
      );
    }

    flameWidgetTest<MyBlocGame>(
      'can emit states',
      createGame: () => MyBlocGame(),
      pumpWidget: _pumpWidget,
      verify: (game, tester) async {
        game.read<InventoryCubit>().selectBow();

        expect(cubit.state, equals(InventoryState.bow));
      },
    );

    flameTest<MyBlocGame>(
      'read throws exection when game is not attached yet',
      createGame: () => MyBlocGame(),
      verify: (game) {
        expect(() => game.read<InventoryCubit>(), throwsException);
      },
    );

    flameTest<MyBlocGame>(
      'adds component to queue when is not attached',
      createGame: () => MyBlocGame(),
      verify: (game) {
        game.add(InventoryComponent());
        game.update(0);

        expect(game.subscriptionQueue.length, equals(1));
      },
    );

    flameTest<MyBlocGame>(
      'runs the queue when game is attached',
      createGame: () => MyBlocGame(),
      verify: (game) {
        final component = MockInventoryComponent();

        game.prepareComponent(component);

        game.onAttach();

        verify(() => component.subscribe(game)).called(1);
      },
    );

    flameWidgetTest<MyBlocGame>(
      'init components with the initial state',
      createGame: () => MyBlocGame(),
      pumpWidget: _pumpWidget,
      verify: (game, tester) async {
        final component = InventoryComponent();
        game.add(component);

        expect(component.state, equals(InventoryState.sword));
      },
    );

    flameWidgetTest<MyBlocGame>(
      'components listen to changes',
      createGame: () => MyBlocGame(),
      pumpWidget: _pumpWidget,
      verify: (game, tester) async {
        final component = InventoryComponent();
        game.add(component);
        game.read<InventoryCubit>().selectBow();

        expect(component.state, equals(InventoryState.sword));
      },
    );
  });
}
