import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// Base class to encapsulate builder functions and required variables.
/// You should create your own subclass of this class and implement
/// three functions with user-defined logic:
/// - [buildOnMessage] - this function is responsible on building loading screen
///   using data from received progress message
/// - [isGameLoadingFinished] - while receiving messages, StreamBuilder checks,
///   if the message indicating that loading process is finished. If true,
///   the [buildTransitionToGame] will be invoked instead of StreamBuilder. See
///   [buildOnStreamData] for details
/// - [buildTransitionToGame] is responsible for rendering game widget,
///   optionally with a transition animation from loading screen.

abstract class LoadingWidgetBuilder<M> {
  late Widget gameWidget;
  late Game game;
  late GameErrorWidgetBuilder? errorBuilder;

  final _loadingCompleter = Completer<void>();

  /// StreamBuilder wrapped by FutureBuilder. When game loading process is
  /// finished, FutureBuilder removes StreamBuilder from widgets thee. This
  /// allows to avoid unnecessary rebuilds on every future progress messages
  /// received from the game.
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

  /// Reimplement this if you want to process [snapshot] yourself.
  @mustCallSuper
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

  /// This function is responsible on building loading screen using data from
  /// received progress message
  Widget buildOnMessage(BuildContext context, M message);

  /// Function is responsible for rendering game widget, optionally with a
  /// transition animation from loading screen.
  Widget buildTransitionToGame(BuildContext context);

  /// While receiving messages, StreamBuilder checks, if the message indicating
  /// that loading process is finished. If true, the [buildTransitionToGame]
  /// will be invoked instead of StreamBuilder. See [buildOnStreamData] for
  /// details
  bool isGameLoadingFinished(M message);
}
