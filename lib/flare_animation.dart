import 'dart:ui';

import "flame.dart";
import "package:flare_flutter/flare.dart";

class FlareAnimation {

  final FlutterActorArtboard artboard;

  FlareAnimation(this.artboard);

  static load(String fileName) async {
    final actor = FlutterActor();
    await actor.loadFromBundle(Flame.bundle, fileName);

    return FlareAnimation(actor.makeArtboard());
  }

  void render(Canvas canvas) {
    artboard.draw(canvas);
  }
}
