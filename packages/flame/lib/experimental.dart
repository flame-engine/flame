/// Classes and components in this sub-module are considered experimental,
/// that is, their API may still be incomplete and subject to change at a more
/// rapid pace than the rest of the Flame code.
///
/// However, do not feel discouraged to use this functionality: on the contrary,
/// consider this as a way to help the Flame community by beta-testing new
/// components.
///
/// After the components lived here for some time, and when we gain more
/// confidence in their robustness, they will be moved out into the main Flame
/// library.
export 'src/camera/behaviors/bounded_position_behavior.dart'
    show BoundedPositionBehavior;
export 'src/camera/behaviors/follow_behavior.dart' show FollowBehavior;
export 'src/camera/camera_component.dart' show CameraComponent;
export 'src/camera/viewfinder.dart' show Viewfinder;
export 'src/camera/viewport.dart' show Viewport;
export 'src/camera/viewports/circular_viewport.dart' show CircularViewport;
export 'src/camera/viewports/fixed_aspect_ratio_viewport.dart'
    show FixedAspectRatioViewport;
export 'src/camera/viewports/fixed_size_viewport.dart' show FixedSizeViewport;
export 'src/camera/viewports/max_viewport.dart' show MaxViewport;
export 'src/camera/world.dart' show World;
export 'src/events/component_mixins/drag_callbacks.dart' show DragCallbacks;
export 'src/events/component_mixins/tap_callbacks.dart' show TapCallbacks;
export 'src/events/flame_game_mixins/has_draggable_components.dart'
    show HasDraggableComponents;
export 'src/events/flame_game_mixins/has_draggables_bridge.dart'
    show HasDraggablesBridge;
export 'src/events/flame_game_mixins/has_tappable_components.dart'
    show HasTappableComponents;
export 'src/events/flame_game_mixins/has_tappables_bridge.dart'
    show HasTappablesBridge;
export 'src/events/messages/drag_cancel_event.dart' show DragCancelEvent;
export 'src/events/messages/drag_end_event.dart' show DragEndEvent;
export 'src/events/messages/drag_start_event.dart' show DragStartEvent;
export 'src/events/messages/drag_update_event.dart' show DragUpdateEvent;
export 'src/events/messages/tap_cancel_event.dart' show TapCancelEvent;
export 'src/events/messages/tap_down_event.dart' show TapDownEvent;
export 'src/events/messages/tap_up_event.dart' show TapUpEvent;
export 'src/experimental/fixed_integer_resolution_viewport.dart'
    show FixedIntegerResolutionViewport;
export 'src/experimental/geometry/shapes/circle.dart' show Circle;
export 'src/experimental/geometry/shapes/polygon.dart' show Polygon;
export 'src/experimental/geometry/shapes/rectangle.dart' show Rectangle;
export 'src/experimental/geometry/shapes/rounded_rectangle.dart'
    show RoundedRectangle;
export 'src/experimental/geometry/shapes/shape.dart' show Shape;
export 'src/experimental/has_game_reference.dart' show HasGameReference;
