import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class LoadingScreenExample extends FlameGame {
  LoadingScreenExample();

  static const description = '''
  Just enjoy how the progress bar fills and numbers grows...
  The loading screen and in-game components are using the same API and same 
  message stream.
  ''';

  final _progressNotifier = GameLoadProgressNotifier<ProgressMessage>();

  /// Override [progressNotifier] getter with specifying target message type.
  /// Is necessary to avoid [dynamic] types.
  @override
  GameLoadProgressNotifier<ProgressMessage> get progressNotifier =>
      _progressNotifier;

  double anyProgressEmulation = 0;
  int messagesSent = 0;

  @override
  FutureOr<void> onLoad() async {
    /// the message will be send to loading screen, if the one is specified
    progressNotifier.reportLoadingProgress(
      const ProgressMessage(message: 'onLoad started', progress: 1),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        message: 'Something happen while loading...',
        progress: 50,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        message: '...almost done!..',
        progress: 90,
      ),
    );

    add(
      TextComponent(text: 'This is in-game text components')
        ..anchor = Anchor.topCenter
        ..x = size.x / 2
        ..y = 50,
    );

    /// These components will receive notifications during game loop.
    add(InGameProgressText(verticalPosition: 100, size: size));
    add(InGameProgressText(verticalPosition: 150, size: size));

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        message: 'Finished! Be ready to play!',
        progress: 100,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    /// You should to decide, what type of message would be trigger for
    /// showing game widget. You should to sent such message manually and
    /// also manually build game widget in loading screen component.
    /// See [_LoadingScreenExampleWidgetState.build]
    progressNotifier.reportLoadingProgress(const ProgressMessage.finished());

    return super.onLoad();
  }

  /// This is just an example of sending messages to game components.
  @override
  void update(double dt) {
    anyProgressEmulation += dt;
    final probability = Random().nextInt(100);
    if (probability < 1) {
      messagesSent++;
      progressNotifier.reportLoadingProgress(
        ProgressMessage(
          message: 'The notification message #$messagesSent',
          progress: (anyProgressEmulation * 100).toInt(),
        ),
      );
    }
    super.update(dt);
  }
}

/// A message strict type. You should to define an immutable message class for
/// exchanging between game and components. You also could to use just [String]
/// and even [dynamic], but the last option looks like heavy anti-pattern.
@immutable
class ProgressMessage {
  const ProgressMessage({required this.message, required this.progress});

  /// Just for fast illustration - a special constructor to indicate, that
  /// [Game.onLoad] is finished.
  const ProgressMessage.finished()
      : message = '',
        progress = 101;

  final String message;
  final int progress;
}

/// The loading screen widget with animated progress bar anf fade effect
/// when displaying the game.
class LoadingScreenExampleWidget extends StatefulWidget
    with LoadingWidgetMixin<ProgressMessage> {
  LoadingScreenExampleWidget({super.key});

  @override
  State<LoadingScreenExampleWidget> createState() =>
      _LoadingScreenExampleWidgetState();
}

class _LoadingScreenExampleWidgetState extends State<LoadingScreenExampleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String text = '';
  double value = 0;
  bool showGame = false;

  /// Message listener should be initialized here. The best place is the end of
  /// function to minimize a chance to loose an message, because everything is
  /// asynchronous
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() => setState(() {}));

    /// Just call this and everything will work!
    widget.initMessageListener(onProgressMessage);
  }

  /// Process received messages here.
  /// This is a place for calling [setState] or whatever you prefer to
  /// use for widget's state management.
  void onProgressMessage(ProgressMessage message) {
    setState(() {
      if (message.progress == 101) {
        showGame = true;
        _controller.value = 0;
        _controller.animateTo(
          1,
          duration: const Duration(seconds: 3),
          curve: Curves.easeOut,
        );
      } else {
        value = message.progress / 100;
        text = message.message;
        _controller.animateTo(
          value,
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// This is the game's widget. You should manually decide, when it is the
    /// time to show it. But in return you have ability to add some effects!
    if (showGame) {
      return Opacity(
        opacity: _controller.value,
        child: widget.gameWidget(context),
      );
    }

    /// This is the loading screen
    return Center(
      child: Container(
        width: double.infinity,
        height: 75.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
            LinearProgressIndicator(
              value: _controller.value,
              semanticsLabel: 'Game loading progress',
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of a component which receive messages during game loop.
/// Just add [ProgressListener] mixin and implement [onProgressMessage]
/// function - the rest of configuration will be made by Flame.
class InGameProgressText extends TextComponent
    with ProgressListener<ProgressMessage> {
  InGameProgressText({required double verticalPosition, required super.size}) {
    anchor = Anchor.topLeft;
    x = 10;
    y = verticalPosition;
    text = 'This will show in-game progress message';
  }

  @override
  FutureOr<void> onLoad() {
    return super.onLoad();
  }

  /// Just change the text here, but you might to do some more complex!
  @override
  void onProgressMessage(ProgressMessage message) {
    text = '${message.message}. The progress is: ${message.progress}';
  }
}
