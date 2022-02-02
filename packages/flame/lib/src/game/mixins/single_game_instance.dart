
import '../../components/component.dart';
import 'game.dart';

mixin SingleGameInstance on Game {
  @override
  void onMount() {
    Component.staticGameInstance = this;
    super.onMount();
  }

  @override
  void onRemove() {
    super.onRemove();
    Component.staticGameInstance = null;
  }
}
