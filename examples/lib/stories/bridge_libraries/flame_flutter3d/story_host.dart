import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter3d/flutter3d.dart' show DepthRange, GraphicsDevice;
import 'package:flutter3d_cpu/flutter3d_cpu.dart' show CpuDevice;

/// Shows a game with a 3D layer, and lets its device go when the story is
/// left: the world lives as long as the game, not the widget, so without
/// [HasFlutter3d.dispose] every visit to a story would keep a GPU context.
class Flutter3dStory<G extends HasFlutter3d> extends StatefulWidget {
  const Flutter3dStory({
    required this.create,
    this.overlays = const {},
    super.key,
  });

  final G Function() create;

  /// Flutter widgets over the game, shown from the start.
  final Map<String, Widget Function(BuildContext, G)> overlays;

  @override
  State<Flutter3dStory<G>> createState() => _Flutter3dStoryState<G>();
}

class _Flutter3dStoryState<G extends HasFlutter3d>
    extends State<Flutter3dStory<G>> {
  late final G _game = widget.create();

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flutter3dFlameWidget(
      game: _game,
      overlayBuilderMap: {
        for (final MapEntry(:key, :value) in widget.overlays.entries)
          key: (context, Game game) => value(context, game as G),
      },
      initialActiveOverlays: widget.overlays.keys.toList(),
    );
  }
}

/// Which graphics API the 3D layer opened on.
///
/// flutter3d does not name its devices, so this tells them apart by what
/// they are: on the web WebGL2 is the one with OpenGL's depth range, and on
/// a native build the software rasterizer is the one that is not Impeller.
String backendName(GraphicsDevice device) {
  if (kIsWeb) {
    return device.depthRange == DepthRange.negativeOneToOne
        ? 'WebGL2'
        : 'WebGPU';
  }
  return device is CpuDevice ? 'CPU' : 'Impeller';
}
