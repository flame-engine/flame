/// Used to define which coordinate system a given top-level component respects.
///
/// Normally components live in the "game" coordinate system, which just means
/// they respect both the camera and viewport.
enum PositionType {
  /// Default type. Respects camera and viewport (applied on top of widget).
  game,

  /// Respects viewport only (ignores camera) (applied on top of widget).
  viewport,

  /// Position in relation to the coordinate system of the Flutter game widget
  /// (i.e. the raw canvas).
  widget,
}
