import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class LoadingWidgetBuilder<M> {
  late final Widget gameWidget;
  late final Game game;
  late final GameErrorWidgetBuilder? errorBuilder;

  final _loadingCompleter = Completer<void>();

  Widget createBuilder(Stream<M> stream) => FutureBuilder<void>(
        future: _loadingCompleter.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildTransitionToGame(context);
          } else {
            return StreamBuilder(
              builder: buildOnStreamData,
              stream: stream,
            );
          }
        },
      );

  Widget buildOnStreamData(BuildContext context, AsyncSnapshot<M> snapshot) {
    if (snapshot.hasError) {
      if (errorBuilder == null) {
        throw Error.throwWithStackTrace(
          snapshot.error!,
          snapshot.stackTrace!,
        );
      } else {
        return errorBuilder!(context, snapshot.error!);
      }
    }

    if (snapshot.hasData) {
      final message = snapshot.data as M;
      if (isGameLoadingFinished(message)) {
        _loadingCompleter.complete();
      }
      return buildOnMessage(context, message);
    }

    return Container();
  }

  Widget buildOnMessage(BuildContext context, M message);

  Widget buildTransitionToGame(BuildContext context);

  bool isGameLoadingFinished(M message);
}
