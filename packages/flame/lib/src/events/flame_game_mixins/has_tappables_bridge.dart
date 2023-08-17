import 'package:flame/src/events/component_mixins/tap_callbacks.dart';

/// Mixin that can be added to a game to indicate that is has Tappable
/// components (in addition to components with [TapCallbacks]).
///
/// This is a temporary mixin to facilitate the transition between the old and
/// the new event system. In the future it will be deprecated.
mixin HasTappablesBridge {}
