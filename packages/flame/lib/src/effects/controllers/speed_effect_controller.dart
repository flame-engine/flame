
import 'effect_controller.dart';

class SpeedEffectController extends EffectController {
  SpeedEffectController(this.child, {required this.speed}) : super.empty();

  final EffectController child;

  final double speed;

  @override
  double advance(double dt) {
    // TODO: implement advance
    throw UnimplementedError();
  }

  @override
  // TODO: implement completed
  bool get completed => throw UnimplementedError();

  @override
  // TODO: implement duration
  double? get duration => throw UnimplementedError();

  @override
  // TODO: implement progress
  double get progress => throw UnimplementedError();

  @override
  double recede(double dt) {
    // TODO: implement recede
    throw UnimplementedError();
  }

  @override
  void setToEnd() {
    // TODO: implement setToEnd
  }

  @override
  void setToStart() {
    // TODO: implement setToStart
  }

}
