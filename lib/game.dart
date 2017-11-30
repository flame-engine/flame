import 'dart:ui';
import 'dart:typed_data';

abstract class Game {
  FrameCallback _previousOnBeginFrame;
  VoidCallback _previousOnDrawFrame;
  PointerDataPacketCallback _previousOnPointerDataPacket;

  Duration _previous = Duration.ZERO;

  void update(double t);

  void render(Canvas canvas);

  start() {
    _previousOnBeginFrame = window.onBeginFrame;
    _previousOnDrawFrame = window.onDrawFrame;
    _previousOnPointerDataPacket = window.onPointerDataPacket;

    window.onBeginFrame = _gameLoop;

    window.scheduleFrame();
  }

  stop() {
    window.onBeginFrame = _previousOnBeginFrame;
    window.onDrawFrame = _previousOnDrawFrame;
    window.onPointerDataPacket = _previousOnPointerDataPacket;
  }

  FrameCallback get _gameLoop => (now) {
    var recorder = new PictureRecorder();
    var canvas = new Canvas(
      recorder,
      new Rect.fromLTWH(0.0, 0.0, window.physicalSize.width, window.physicalSize.height),
    );

    Duration delta = now - _previous;
    if (_previous == Duration.ZERO) {
      delta = Duration.ZERO;
    }
    _previous = now;

    var t = delta.inMicroseconds / Duration.MICROSECONDS_PER_SECOND;

    update(t);
    render(canvas);

    var deviceTransform = new Float64List(16)
      ..[0] = 1.0 // window.devicePixelRatio
      ..[5] = 1.0 // window.devicePixelRatio
      ..[10] = 1.0
      ..[15] = 1.0;

    var builder = new SceneBuilder()
      ..pushTransform(deviceTransform)
      ..addPicture(Offset.zero, recorder.endRecording())
      ..pop();

    window.render(builder.build());
    window.scheduleFrame();
  }
;
}