import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';

/// The [SpawnComponent] is a non-visual component which can spawn
/// [PositionComponent]s randomly within a set [area]. If [area] is not set it
/// will use the size of the nearest ancestor that provides a size.
///
/// If you want your components to spawn with a static period, just set [period]
/// and if you want them to spawn within a random period set [minPeriod] and
/// [maxPeriod].
class SpawnComponent extends Component {
  SpawnComponent({
    required this.factory,
    this.area,
    this.within = true,
    double? period,
    double? minPeriod,
    double? maxPeriod,
    Random? random,
    super.key,
  })  : _period = period ?? 0,
        _random = random ?? _randomFallback,
        assert(
          period != null || (minPeriod != null && maxPeriod != null),
          'Either the static period must be defined, or both minPeriod and '
          'maxPeriod must be defined',
        );

  /// The function used to create new components to spawn.
  ///
  /// [amount] is the amount of components that the [SpawnComponent] has spawned
  /// so far.
  PositionComponent Function(int amount) factory;

  /// The area where the components should be spawned.
  Shape? area;

  /// Whether the random point should be within the [area] or along its edges.
  bool within;

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
  static final Random _randomFallback = Random();

  /// The amount of spawned components.
  int amount = 0;

  @override
  FutureOr<void> onLoad() async {
    if (area == null) {
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
        component.position = area!.randomPoint(
          random: _random,
          within: within,
        );
        parent?.add(component);
        updatePeriod();
        amount++;
      },
    );
    timer = timerComponent.timer;
    add(timerComponent);
  }
}
