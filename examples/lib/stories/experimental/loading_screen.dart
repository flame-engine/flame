import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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

  bool _gameLoadingFinished = false;

  set gameLoadingFinished(bool finished) {
    _gameLoadingFinished = finished;
    if (finished) {
      progressNotifier.reportLoadingProgress(
        const ProgressMessage(
          text: 'Finished! Be ready to play!',
          progress: 100,
        ),
      );
    }
  }

  bool get gameLoadingFinished => _gameLoadingFinished;

  @override
  FutureOr<void> onLoad() async {
    /// the message will be send to loading screen, if the one is specified
    progressNotifier.reportLoadingProgress(
      const ProgressMessage(text: 'onLoad started', progress: 1),
    );

    await Future<void>.delayed(const Duration(seconds: 1));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        text: 'Something happen while loading...',
        progress: 50,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        text: '...almost done!..',
        progress: 90,
      ),
    );

    final captionComponent =
        TextComponent(text: 'This is in-game text components')
          ..anchor = Anchor.topCenter
          ..x = size.x / 2
          ..y = 100;

    final path = Path();
    path.addOval(Rect.fromCircle(center: const Offset(0, 25), radius: 30));
    final effect = MoveAlongPathEffect(
      path,
      EffectController(duration: 5, infinite: true),
    );
    captionComponent.add(effect);

    add(captionComponent);

    /// These components will receive notifications during game loop.
    add(InGameProgressText(verticalPosition: 200, size: size));
    add(InGameProgressText(verticalPosition: 250, size: size));

    await Future<void>.delayed(const Duration(seconds: 5));

    /// You should to decide, what type of message would be trigger for
    /// showing game widget. You should to sent such message manually and
    /// also manually build game widget in loading screen component.
    /// See [LoadingWidgetBuilder.buildTransitionToGame]
    gameLoadingFinished = true;

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
          text: 'The notification message #$messagesSent',
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
  const ProgressMessage({required this.text, required this.progress});

  final String text;
  final int progress;
}

/// Stateless immutable class responsible to call widgets depending on received
/// message
class ExampleBuilder extends LoadingWidgetBuilder<ProgressMessage> {
  /// A global key to let Flutter know, that [AnimatedSwitcher] is the same
  /// both in [buildOnMessage] and at [buildTransitionToGame]
  static final animatedSwitcherKey = GlobalKey();

  @override
  Widget buildOnMessage(BuildContext context, ProgressMessage message) {
    return AnimatedSwitcher(
      key: animatedSwitcherKey,
      duration: const Duration(seconds: 3),
      child: _buildLoadingScreen(message.text, message.progress),
    );
  }

  Widget _buildLoadingScreen(String message, int progress) =>
      LoadingScreenExampleWidget(
        text: message,
        progress: progress / 100,
      );

  @override
  Widget buildTransitionToGame(BuildContext context) {
    return AnimatedSwitcher(
      key: animatedSwitcherKey,
      duration: const Duration(seconds: 3),
      child: gameWidget,
    );
  }

  @override
  bool isGameLoadingFinished(ProgressMessage message) =>
      (game as LoadingScreenExample).gameLoadingFinished;
}

/// The loading screen widget with animated progress bar anf fade effect
/// when displaying the game.
/// This is just ordinary Flutter widget without any special "relationships"
/// with Flame. You can use everything you want to be used as a "progress bar"
class LoadingScreenExampleWidget extends StatefulWidget {
  const LoadingScreenExampleWidget({
    super.key,
    required this.text,
    required this.progress,
  });

  final String text;
  final double progress;

  @override
  State<LoadingScreenExampleWidget> createState() =>
      _LoadingScreenExampleWidgetState();
}

class _LoadingScreenExampleWidgetState extends State<LoadingScreenExampleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Message listener should be initialized here. The best place is the end of
  /// function to minimize a chance to loose an message, because everything is
  /// asynchronous
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LoadingScreenExampleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.animateTo(
        widget.progress,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: double.infinity,
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                widget.text,
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
    text = '${message.text}. The progress is: ${message.progress}';
  }
}
