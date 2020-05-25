import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';

class Joystick extends Component {
  double _movementRadius = 200;
  double _radiusSquare = 40000;
  Offset _offset = Offset.zero;

  /// The base part of the joystick. It's like the area in which the stick swivels.
  ///
  /// You shouldn't change it's position manually, but rather use the Joystick methods.
  final SpriteComponent base = SpriteComponent()..anchor = Anchor.center;

  /// The knob part of the joystick, which in real life is placed on top of the stick.
  ///
  /// It's used to measure the direction and amplitude of the joystick's input,
  /// according to it's position relative to the base part.
  ///
  /// You shouldn't change it's position manually, but rather use the Joystick methods.
  final SpriteComponent knob = SpriteComponent()..anchor = Anchor.center;

  /// States whether the joystick's base should always stay at its position
  /// or whether it should move when the knob exceeds the movement radius.
  bool fixedPosition = true;

  /// States whether this component should be rendered or not.
  bool visible = true;

  /// Defines how far apart the joystick's knob and base can be from each other.
  /// The amplitude of the joystick's offset is measured as the distance between
  /// the base and the knob, divided by this radius.
  ///
  /// This radius is used to limit the knob's movement relative to the base (if
  /// `fixedPosition` is set to `true`), or move the base when it's distance from
  /// the knob exceeds this radius (when `fixedPosition` is set to `false`).
  double get movementRadius => _movementRadius;

  set movementRadius(double px) {
    _movementRadius = px;
    _radiusSquare = px * px;
  }

  /// Represents the relative offset of the joystick from the center.
  /// The offset's distance is in range 0-1, indicating how far the joystick is
  /// pushed from the center to the maximum radius (movementRadius).
  Offset get offset => _offset;

  @override
  bool isHud() => true;

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    base.render(canvas);
    canvas.restore();
    canvas.save();
    knob.render(canvas);
  }

  @override
  void update(double dt) {
    base.update(dt);
    knob.update(dt);
  }

  /// Moves the virtual joystick knob to the given position on the game widget,
  /// updating the joystick's offset according to the new state.
  ///
  /// When the given position exceeds the joystick's movement radius,
  /// if fixedPosition is true the knob will be limited to stay in the range of
  /// that radius, otherwise the virtual socket will be moved to stay in that range.
  void moveKnob(Offset position) {
    if (position == null) return;

    knob.x = position.dx;
    knob.y = position.dy;
    final dx = knob.x - base.x;
    final dy = knob.y - base.y;
    final ds = dx * dx + dy * dy;

    if (ds > _radiusSquare) {
      final d = sqrt(ds);
      _offset = Offset(dx / d, dy / d);
      if (fixedPosition) {
        knob.x = base.x + movementRadius * _offset.dx;
        knob.y = base.y + movementRadius * _offset.dy;
      } else {
        base.x = knob.x - movementRadius * _offset.dx;
        base.y = knob.y - movementRadius * _offset.dy;
      }
    } else
      _offset = Offset(dx / movementRadius, dy / movementRadius);
  }

  /// Releases the knob, setting it's position to the position of the base and
  /// setting the joystick's offset to zero.
  void releaseKnob() {
    knob.x = base.x;
    knob.y = base.y;
    _offset = Offset.zero;
  }

  /// Sets the position of both the knob and socket.
  void setPosition(double x, double y) {
    base.x = knob.x = x;
    base.y = knob.y = y;
    _offset = Offset.zero;
  }

  /// Places both the socket and the knob at the given position and makes the
  /// joystick visible.
  void showAt(Offset position) {
    setPosition(position.dx, position.dy);
    visible = true;
  }

  /// Makes the joystick invisible and calls `releaseKnob()`.
  void hideAndRelease() {
    visible = false;
    releaseKnob();
  }
}
