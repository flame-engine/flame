part of flame_splash_screen;

/// Controller enables you to start the animation whenever you want with
/// [autoStart] option and customize animation duration as well.
class FlameSplashController {
  /// Creates a [FlameSplashController].
  FlameSplashController({
    Duration fadeInDuration = const Duration(milliseconds: 750),
    Duration waitDuration = const Duration(seconds: 2),
    Duration fadeOutDuration = const Duration(milliseconds: 450),
    this.autoStart = true,
  })  : _stepController = _FlameSplashControllerStep(0),
        _durations = _FlameSplashDurations(
          fadeInDuration,
          waitDuration,
          fadeOutDuration,
        );

  /// Defines if you want to start the animations right after widget mount.
  final bool autoStart;

  // internally created
  final _FlameSplashDurations _durations;
  final _FlameSplashControllerStep _stepController;

  // internal control
  FlameSplashControllerState _state = FlameSplashControllerState.idle;
  bool _hasSetup = false;
  int _stepsAmount = 0;
  late VoidCallback _onFinish;

  /// Displays the actual state of the controller regarding the animation.
  FlameSplashControllerState get state => _state;

  /// Method used to start the animation, do not call if you set [autoStart] to
  /// true.
  void start() {
    assert(
      _hasSetup,
      'This controller is not being used by any FlameSplashScreen widget. '
      'Start it only after widget mount.',
    );
    assert(
      _state != FlameSplashControllerState.started,
      'This controller has been already started, verify if autoStart has been '
      'specified',
    );

    _state = FlameSplashControllerState.started;
    _tickStep(0);
  }

  /// Called by the [start] method; this is only exposed for testing purposes.
  @visibleForTesting
  void setup(
    int steps,
    VoidCallback onFinish,
  ) {
    _onFinish = onFinish;
    _stepsAmount = steps;
    _hasSetup = true;
    if (autoStart) {
      start();
    }
  }

  Future<void> _tickStep(int index) async {
    _stepController.value = index;
    await Future<void>.delayed(_durations.total);
    final finished = index >= _stepsAmount - 1;
    if (finished) {
      _state = FlameSplashControllerState.finished;
      _onFinish();
      return;
    }
    _tickStep(index + 1);
  }

  /// Properly disposes of this controller.
  /// Must be called after no longer used.
  void dispose() {
    _stepController.dispose();
  }
}

/// Represents the state of the splash screen.
enum FlameSplashControllerState {
  /// Not started yet, but ready to start.
  /// Note that if autoStart is set, this stage will be skipped.
  idle,

  /// Started and currently running through the steps.
  started,

  /// Finished to run through all steps.
  finished,
}

class _FlameSplashControllerStep extends ValueNotifier<int> {
  _FlameSplashControllerStep(super.value);
}

class _FlameSplashDurations {
  const _FlameSplashDurations(
    this.fadeInDuration,
    this.waitDuration,
    this.fadeOutDuration,
  );

  final Duration fadeInDuration;
  final Duration waitDuration;
  final Duration fadeOutDuration;

  Duration get total {
    return fadeInDuration + fadeOutDuration + waitDuration;
  }
}
