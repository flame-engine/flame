import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/host/has_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;

/// A day of [AtmosphereCycle] run on Flame's clock, on the 3D world of the
/// `HasFlutter3d` game it is in: the sky, the ambient light and [sun].
///
/// [time] advances by [rate] a second (a game whose day lasts a race sets
/// it so), and [current] is the air right now.
///
/// **The fog reaches the frame by itself.** It is the one part a scene does
/// not hold, and a game had to know to read [fog] into its own
/// `renderSettings`; one that did not saw a sky turn to dusk over a road
/// still in noon's haze. It is written into `HasFlutter3d.fog3d`, which
/// the game's settings draw with unless it chose its own.
///
/// The sky is written into the game's `clearColor`. A
/// `Flutter3dFlameWidget` handed a `clearColor` of its own draws that
/// instead, as it says: leave it out for the day to show.
class AtmosphereComponent extends Component {
  AtmosphereComponent({
    required this.cycle,
    this.sun,
    this.time = 0.0,
    this.rate = 1.0,
  }) : current = cycle.at(time);

  final AtmosphereCycle cycle;

  /// The light the sun's colour and intensity go onto, if any.
  final LightNode? sun;

  /// Where in the cycle the day is.
  double time;

  /// How much [time] passes a second of play.
  double rate;

  /// The air now.
  Atmosphere current;

  /// The fog to draw with now.
  FogSettings get fog => current.fog;

  @override
  void update(double dt) {
    super.update(dt);
    time += dt * rate;
    current = cycle.at(time);
    final game = findGame();
    if (game is HasFlutter3d && game.has3d) {
      current.applyTo(game.scene, sun: sun, clearColor: game.clearColor);
      game.fog3d = current.fog;
    }
  }
}
