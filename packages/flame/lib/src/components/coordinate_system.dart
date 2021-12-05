/// Used to define which coordinate system a given top-level component respects.
///
/// Normally components live in the "game" coordinate system, which just means
/// they respect both the camera and viewport.
enum CoordinateSystem {
  /// Default system. Respects camera and viewport (applied on top of widget).
  game,

  /// Respects viewport only (ignores camera) (applied on top of widget).
  viewportOnly,

  /// The coordinate system of the Flutter game widget (i.e. the raw canvas
  /// system).
  widget,
}
