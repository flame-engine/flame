import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class LoadingWidgetBuilder<M> {
  late final Widget gameWidget;
  late final Game game;

  StreamBuilder<M> createStreamBuilder(Stream<M> stream) => StreamBuilder(
        builder: buildOnStreamData,
        stream: stream,
      );

  Widget buildOnStreamData(BuildContext context, AsyncSnapshot<M> snapshot) {
    if (snapshot.hasData) {
      return buildOnMessage(context, snapshot.data as M);
    }

    return Container();
  }

  Widget buildOnMessage(BuildContext context, M message);
}
