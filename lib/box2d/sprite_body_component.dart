import '../components/component.dart';
import 'body_component.dart';
import 'box2d_game.dart';

class SpriteBodyComponent extends BodyComponent {
  final SpriteComponent spriteComponent;

  SpriteBodyComponent(this.spriteComponent, Box2DGame game) : super(game) {
    game.addLater(spriteComponent);
  }

  @override
  bool loaded() => body.isActive() && spriteComponent.loaded();

  @override
  void update(double t) {
    super.update(t);
    final screenPosition = viewport.getWorldToScreen(center);
    final width = spriteComponent.width * viewport.scale;
    final height = spriteComponent.height * viewport.scale;
    spriteComponent
      ..angle = -body.getAngle()
      ..x = screenPosition.x
      ..y = screenPosition.y
      ..width = width
      ..height = height;
  }
}
