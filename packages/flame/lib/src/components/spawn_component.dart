import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/math.dart';

/// {@template spawn_component}
/// The [SpawnComponent] is a non-visual component which can spawn
/// [PositionComponent]s randomly within a set [area]. If [area] is not set it
/// will use the size of the nearest ancestor that provides a size.
/// [period] will set the static time interval for when it will spawn new
/// components.
/// If you want to use a non static time interval, use the
/// [SpawnComponent.periodRange] constructor.
/// If you want to set the position of the spawned components yourself inside of
/// the [factory], set [selfPositioning] to true.
/// {@endtemplate}
class SpawnComponent extends Component {
  /// {@macro spawn_component}
  SpawnComponent({
    required this.factory,
    required double period,
    this.area,
    this.within = true,
    this.selfPositioning = false,
    Random? random,
    super.key,
  })  : assert(
          !(selfPositioning && area != null),
          "Don't set an area when you are using selfPositioning=true",
        ),
        _period = period,
        _random = random ?? randomFallback;

  /// Use this constructor if you want your components to spawn within an
  /// interval time range.
  /// [minPeriod] will be the minimum amount of time before the next component
  /// spawns and [maxPeriod] will be the maximum amount of time before it
  /// spawns.
  SpawnComponent.periodRange({
    required this.factory,
    required double minPeriod,
    required double maxPeriod,
    this.area,
    this.within = true,
    this.selfPositioning = false,
    Random? random,
    super.key,
  })  : assert(
          !(selfPositioning && area != null),
          "Don't set an area when you are using selfPositioning=true",
        ),
        _period = minPeriod +
            (random ?? randomFallback).nextDouble() * (maxPeriod - minPeriod),
        _random = random ?? randomFallback;

  /// The function used to create new components to spawn.
  ///
  /// [amount] is the amount of components that the [SpawnComponent] has spawned
  /// so far.
  PositionComponent Function(int amount) factory;

  /// The area where the components should be spawned.
  Shape? area;

  /// Whether the random point should be within the [area] or along its edges.
  bool within;

  /// Whether the spawned components positions shouldn't be given a position,
  /// so that they can continue to have the position that they had after they
  /// came out of the [factory].
  bool selfPositioning;

  /// The timer that is used to control when components are spawned.
  late final Timer timer;

  /// The time between each component is spawned.
  double get period => _period;
  set period(double newPeriod) {
    _period = newPeriod;
    timer.limit = _period;
  }

  double _period;

  /// The minimum amount of time that has to pass until the next component is
  /// spawned.
  double? minPeriod;

  /// The maximum amount of time that has to pass until the next component is
  /// spawned.
  double? maxPeriod;

  /// Whether it is spawning components within a random time frame or at a
  /// static rate.
  bool get hasRandomPeriod => minPeriod != null;

  final Random _random;

  /// The amount of spawned components.
  int amount = 0;

  @override
  FutureOr<void> onLoad() async {
    if (area == null && !selfPositioning) {
      final parentPosition =
          ancestors().whereType<PositionProvider>().firstOrNull?.position ??
              Vector2.zero();
      final parentSize =
          ancestors().whereType<ReadOnlySizeProvider>().firstOrNull?.size ??
              Vector2.zero();
      assert(
        !parentSize.isZero(),
        'The SpawnComponent needs an ancestor with a size if area is not '
        'provided.',
      );
      area = Rectangle.fromLTWH(
        parentPosition.x,
        parentPosition.y,
        parentSize.x,
        parentSize.y,
      );
    }

    void updatePeriod() {
      if (hasRandomPeriod) {
        period = minPeriod! + _random.nextDouble() * (maxPeriod! - minPeriod!);
      }
    }

    updatePeriod();

    final timerComponent = TimerComponent(
      period: _period,
      repeat: true,
      onTick: () {
        final component = factory(amount);
        if (!selfPositioning) {
          component.position = area!.randomPoint(
            random: _random,
            within: within,
          );
        }
        parent?.add(component);
        updatePeriod();
        amount++;
      },
    );
    timer = timerComponent.timer;
    add(timerComponent);
  }
}
