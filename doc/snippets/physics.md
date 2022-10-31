# Physics


## Smooth Angle change with Joystick

```dart
  Vector2 get forward => Vector2(0, -1)..rotate(angle);
  double angularSpeed = 2;

  @override
  void update(double dt) {
    if (joystickComponent.isDragged) {
      angle += lerpDouble(0, forward.angleToSigned(joystickComponent.delta),
          angularSpeed * dt)!;
    }
    super.update(dt);
  }
```


## Arc an Object

```{flutter-app}
:sources: ../flame/examples
:page: snippet_physics_arc
:show: widget code infobox
:width: 180
:height: 160
```

```dart
  Double _initialAngle = 30.0; 
  // 0 is straight up and 30 is slightly to the right.
  Double _initialVelocity = -300; 
  // This is negative to counter gravity and essentially indicates how high the
  // object should arc before gravity takes over.
  Double _gravity = 10; 
  // How many pixels should the object move down per tick?
  Double _windSpeed = 2; 
  // How many pixels should the object move to the right per tick?

  Vector2 _velocity = Vector2(_initialAngle,_initialVelocity);
  @override
  void update(double dt) {
    _velocity.x += _windSpeed;
    _velocity.y += _gravity;    
    position += _velocity * dt;
    
    super.update(dt);
  }
```
