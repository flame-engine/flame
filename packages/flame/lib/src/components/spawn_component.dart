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
/// You can either provide a factory that returns one component or a
/// multiFactory which returns a list of components. In this case the amount
/// parameter will be increased by the number of returned components.
/// {@endtemplate}
class SpawnComponent extends Component {
  /// {@macro spawn_component}
  SpawnComponent({
    required double period,
    PositionComponent Function(int amount)? factory,
    List<PositionComponent> Function(int amount)? multiFactory,
    this.target,
    this.spawnCount,
    this.area,
    this.within = true,
    this.selfPositioning = false,
    this.autoStart = true,
    this.spawnWhenLoaded = false,
    Random? random,
    super.key,
  })  : assert(
          !(selfPositioning && area != null),
          "Don't set an area when you are using selfPositioning=true",
        ),
        assert(
          (factory != null) ^ (multiFactory != null),
          'You need to provide either a factory or a multiFactory, not both.',
        ),
        _period = period,
        multiFactory = multiFactory ?? _wrapFactory(factory!),
        _random = random ?? randomFallback;

  /// Use this constructor if you want your components to spawn within an
  /// interval time range.
  /// [minPeriod] will be the minimum amount of time before the next component
  /// spawns and [maxPeriod] will be the maximum amount of time before it
  /// spawns.
  SpawnComponent.periodRange({
    required double this.minPeriod,
    required double this.maxPeriod,
    PositionComponent Function(int amount)? factory,
    List<PositionComponent> Function(int amount)? multiFactory,
    this.target,
    this.spawnCount,
    this.area,
    this.within = true,
    this.selfPositioning = false,
    this.autoStart = true,
    this.spawnWhenLoaded = false,
    Random? random,
    super.key,
  })  : assert(
          !(selfPositioning && area != null),
          "Don't set an area when you are using selfPositioning=true",
        ),
        _period = minPeriod +
            (random ?? randomFallback).nextDouble() * (maxPeriod - minPeriod),
        multiFactory = multiFactory ?? _wrapFactory(factory!),
        _random = random ?? randomFallback;

  /// The function used to create a new component to spawn.
  ///
  /// [amount] is the amount of components that the [SpawnComponent] has spawned
  /// so far.
  ///
  /// Be aware: internally the component uses a factory that creates a list of
  /// components.
  /// If you have set such a factory it was wrapped to create a list. The
  /// factory getter wraps it again to return the first element of the list and
  /// fails when the list is empty!
  PositionComponent Function(int amount) get factory => (int amount) {
        final result = multiFactory.call(amount);
        assert(
          result.isNotEmpty,
          'The factory call yielded no result, which is required when calling'
          ' the single result factory',
        );
        return result.elementAt(0);
      };

  set factory(PositionComponent Function(int amount) newFactory) {
    multiFactory = _wrapFactory(newFactory);
  }

  static List<PositionComponent> Function(int amount) _wrapFactory(
    PositionComponent Function(int amount) newFactory,
  ) {
    return (int amount) => [newFactory.call(amount)];
  }

  /// The function used to create new components to spawn.
  ///
  /// [amount] is the amount of components that the [SpawnComponent] has spawned
  /// so far.
  List<PositionComponent> Function(int amount) multiFactory;

  /// The area where the components should be spawned.
  Shape? area;

  /// The component that the spawned components should be added to.
  ///
  /// If not set, the components will be added to the parent of the
  /// [SpawnComponent].
  Component? target;

  /// The amount of components that should be spawned until the [SpawnComponent]
  /// is removed from its parent.
  ///
  /// Do note that it is possible to overshoot the [spawnCount] for one tick if
  /// the [multiFactory] returns more components than expected.
  int? spawnCount;

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

  /// Whether the timer automatically starts or not.
  final bool autoStart;

  /// Whether the timer should start when the [SpawnComponent] is loaded.
  final bool spawnWhenLoaded;

  @override
  FutureOr<void> onLoad() async {
    if (area == null && !selfPositioning) {
      final Vector2? maybeProvidedPosition;
      if (target != null) {
        if (target is ReadOnlyPositionProvider) {
          maybeProvidedPosition = (target! as PositionProvider).position;
        } else {
          maybeProvidedPosition = Vector2.zero();
        }
      } else {
        maybeProvidedPosition = null;
      }
      final targetPosition = maybeProvidedPosition ??
          ancestors().whereType<PositionProvider>().firstOrNull?.position ??
          Vector2.zero();

      final Vector2? maybeProvidedSize;
      if (target != null) {
        assert(
          target is ReadOnlySizeProvider,
          'The SpawnComponent needs a target with a size if area is not '
          'provided.',
        );
        maybeProvidedSize = (target! as PositionProvider).position;
      } else {
        maybeProvidedSize = null;
      }
      final targetSize = maybeProvidedSize ??
          ancestors().whereType<ReadOnlySizeProvider>().firstOrNull?.size ??
          Vector2.zero();
      assert(
        !targetSize.isZero(),
        'The SpawnComponent needs an ancestor or target with a size if area is '
        'not provided.',
      );
      area = Rectangle.fromLTWH(
        targetPosition.x,
        targetPosition.y,
        targetSize.x,
        targetSize.y,
      );
    }

    void updatePeriod() {
      if (hasRandomPeriod) {
        period = minPeriod! + _random.nextDouble() * (maxPeriod! - minPeriod!);
      }
    }

    final timerComponent = TimerComponent(
      period: _period,
      repeat: true,
      onTick: () {
        final components = multiFactory(amount);
        if (!selfPositioning) {
          for (final component in components) {
            component.position = area!.randomPoint(
              random: _random,
              within: within,
            );
          }
        }
        (target ?? parent)?.addAll(components);
        updatePeriod();
        amount += components.length;
        if (spawnCount != null && amount >= spawnCount!) {
          timer.stop();
          removeFromParent();
        }
      },
      autoStart: autoStart,
      tickWhenLoaded: spawnWhenLoaded,
    );
    timer = timerComponent.timer;
    add(timerComponent);
  }
}
