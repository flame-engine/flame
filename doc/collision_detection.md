# Collision detection

## Hitbox
The `Hitbox` mixin is used to make detection of gestures on top of your `PositionComponent`s more
accurate. Say that you have a fairly round rock as a `SpriteComponent` for example, then you don't
want to register input that is in the corner of the image where the rock is not displayed. Then you
can use the `Hitbox` mixin to define a more accurate polygon for which the input should be within
for the event to be counted on your component.
