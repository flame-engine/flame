import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Base64SpriteExample extends FlameGame {
  static const String description = '''
    In this example we load a sprite from the a base64 string and put it into a
    `SpriteComponent`.
  ''';

  @override
  Future<void> onLoad() async {
    const exampleUrl =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/'
        '9hAAAAxElEQVQ4jYWTMQ7DIAxFIeoNuAGK1K1ISL0DMwOHzNC5p6iUPeoNOEM7GZ'
        'nPJ/EUbP7Lx7KtIfH91B/L++gs5m5M9NreTN/dEZiVghatwbXvY68UlksyPjprRa'
        'xFGAJZg+uAuSSzzC7rEDirDYAz2wg0RjWRFa/EUwdnQnQ37QFe1Odjrw04AKTTaB'
        'XPAlx8dDaXdNk4rMsc0B7ge/UcYLTZxoFizxCQ/L0DMAhaX4Mzj/uzW6phu3AvtH'
        'UUU4BAWJ6t8x9N/HHcruXjwQAAAABJRU5ErkJggg==';
    final image = await images.fromBase64('shield.png', exampleUrl);
    add(
      SpriteComponent.fromImage(
        image,
        position: size / 2,
        size: Vector2.all(100),
        anchor: Anchor.center,
      ),
    );
  }
}
