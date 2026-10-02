import 'package:bloc/bloc.dart';

enum InventoryState() {
  sword,
  bow,
}

class InventoryCubit() extends Cubit<InventoryState> {
  this : super(InventoryState.sword);

  void selectBow() {
    emit(InventoryState.bow);
  }

  void selectSword() {
    emit(InventoryState.sword);
  }
}
