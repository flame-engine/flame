import '../components/position_component.dart';

export './move_effect.dart';
export './scale_effect.dart';

abstract class PositionComponentEffect {
  void update(double dt);
  bool hasFinished();
  PositionComponent component;
}
