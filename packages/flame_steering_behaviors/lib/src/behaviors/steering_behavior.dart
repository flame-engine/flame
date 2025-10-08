import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

/// {@template steering_behavior}
/// Abstract base class for steering behaviors.
/// {@endtemplate}
abstract class SteeringBehavior<Parent extends Steerable>
    extends Behavior<Parent>
    with Steering {}
