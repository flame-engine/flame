import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';
import 'package:vector_math/vector_math_64.dart';

/// [Shadow3DDecorator] casts a realistic-looking shadow from the component
/// onto the ground.
///
/// This decorator is suitable for games that use an isometric projection.
///
/// The shadows are very flexible, allowing for different positions of sun in
/// the sky, and even supporting airborne objects.
///
/// Still, these are not real 3D shadows cast by real 3D objects on a real 3D
/// terrain, so many limitations apply. For example, the shadow must fall on
/// the flat ground, having the sun too high in the sky is undesirable as it
/// would betray the fact that the component is really flat, etc.
class Shadow3DDecorator extends Decorator {
  Shadow3DDecorator({
    Vector2? base,
    double? ascent,
    double? angle,
    double? xShift,
    double? yScale,
    double? blur,
    double? opacity,
  })  : _base = base?.clone() ?? Vector2.zero(),
        _ascent = ascent ?? 0,
        _angle = angle ?? -1.4,
        _shift = xShift ?? 100.0,
        _scale = yScale ?? 1.0,
        _blur = blur ?? 0,
        _opacity = opacity ?? 0.6;

  /// Coordinates of the point where the component "touches the ground". If the
  /// component is airborne (i.e. [ascent] is non-zero), then this should be the
  /// coordinate of the point where the component would have touched the ground
  /// if it landed.
  ///
  /// This point is in the parent's coordinate space.
  Vector2 get base => _base;
  final Vector2 _base;
  set base(Vector2 value) {
    _base.setFrom(value);
    _transformMatrix = null;
  }

  /// How high is the component above the ground.
  double get ascent => _ascent;
  double _ascent;
  set ascent(double value) {
    _ascent = value;
    _transformMatrix = null;
  }

  /// The amount of skew the shadow is experiencing. The value of 0 corresponds
  /// to the shadow being right behind (or in front of) the object. Positive
  /// shift skews the shadow to the right if it's behind the object, or to the
  /// left if the shadow is in front of the object. Negative shift skews in the
  /// opposite direction.
  ///
  /// This property should be determined by the meridian position of the sun.
  double get xShift => _shift;
  double _shift;
  set xShift(double value) {
    _shift = value;
    _transformMatrix = null;
  }

  /// The length of the shadow relative to the height of the object. If the sun
  /// is 45º above the horizon, this scale will be 1. When the sun is higher in
  /// the sky, the scale factor should be less than 1, and when the sun is
  /// lower, the scale factor ought to be greater than 1.
  double get yScale => _scale;
  double _scale;
  set yScale(double value) {
    _scale = value;
    _transformMatrix = null;
  }

  /// Visual angle between a vertically standing component and the ground. This
  /// angle is determined by your isometric projection. Use negative values
  /// smaller than τ/4 (1.57) in magnitude to create shadows that are behind the
  /// objects. Use positive angles that are slightly above τ/4 to make shadows
  /// that are in front of the objects.
  double get angle => _angle;
  double _angle;
  set angle(double value) {
    _angle = value;
    _transformMatrix = null;
  }

  /// The amount of blur to apply to the shadow. The value of 0 produces crisp
  /// shadows with sharp edges, whereas positive [blur] produces softer-looking
  /// shadows.
  ///
  /// Strictly speaking, the parts of the object that are closer to the ground
  /// ought to experience less blur than those that are higher up. However, this
  /// is not supported by this decorator. Still, you can try setting the amount
  /// of blur proportional to the height of the object, or dependent on its
  /// ascent above the ground.
  double get blur => _blur;
  double _blur;
  set blur(double value) {
    _blur = value;
    _paint = null;
  }

  /// Shadow's intensity. The value of 1 will create a hard pitch-black shadow,
  /// which can only happen when there are no ambient sources of light (e.g. in
  /// a cave). Values close to 0 will make the shadow barely visible, such as
  /// on a cloudy day.
  double get opacity => _opacity;
  double _opacity;
  set opacity(double value) {
    _opacity = value;
    _paint = null;
  }

  Paint? _paint;
  Paint _makePaint() {
    final paint = Paint();
    final color = Color.fromRGBO(0, 0, 0, opacity);
    paint.colorFilter = ColorFilter.mode(color, BlendMode.srcIn);
    if (_blur > 0) {
      paint.imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur / _scale);
    }
    return paint;
  }

  Matrix4? _transformMatrix;
  Matrix4 _makeTransform() {
    return Matrix4.identity()
      ..translate(0.0, 0.0, _scale * _ascent)
      ..setEntry(3, 2, 0.001)
      ..rotateX(_angle)
      ..scale(1.0, _scale)
      ..translate(-base.x - _shift, -base.y - _scale * _ascent);
  }

  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    _transformMatrix ??= _makeTransform();
    _paint ??= _makePaint();

    canvas.saveLayer(null, _paint!);
    canvas.translate(base.x + _shift, base.y);
    canvas.transform(_transformMatrix!.storage);
    draw(canvas);
    canvas.restore();
    draw(canvas);
  }
}
