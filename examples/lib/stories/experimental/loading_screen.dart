import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

const tileSize = 8.0;

class LoadingScreenExample extends FlameGame {
  LoadingScreenExample();

  static const description = '''
  
  ''';

  static const mapSize = 300;
  static const bricksCount = 8000;

  final _progressNotifier = GameLoadProgressNotifier<ProgressMessage>();

  @override
  GameLoadProgressNotifier<ProgressMessage> get progressNotifier =>
      _progressNotifier;

  @override
  FutureOr<void> onLoad() async {
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
      TextComponent(text: 'This text is the game')
        ..anchor = Anchor.topCenter
        ..x = size.x / 2
        ..y = 50,
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(
      const ProgressMessage(
        message: 'Finished! Be ready to play!',
        progress: 100,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    progressNotifier.reportLoadingProgress(const ProgressMessage.finished());

    return super.onLoad();
  }
}

@immutable
class ProgressMessage {
  const ProgressMessage({required this.message, required this.progress});

  const ProgressMessage.finished()
      : message = '',
        progress = 101;

  final String message;
  final int progress;
}

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() => setState(() {}));
    widget.initMessageListener(onNewMessage);
  }

  void onNewMessage(ProgressMessage message) {
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
    if (showGame) {
      return Opacity(
        opacity: _controller.value,
        child: widget.gameWidget(context),
      );
    }
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
