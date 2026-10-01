import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameLoopControls extends StatefulWidget {
  const GameLoopControls({super.key});

  @override
  State<GameLoopControls> createState() => _GameLoopControlsState();
}

class _GameLoopControlsState extends State<GameLoopControls> {
  Future<bool>? _paused;
  final _stepTimeController = TextEditingController();
  double get stepTime => double.tryParse(_stepTimeController.text) ?? 0;

  @override
  void initState() {
    _paused = Repository.getPaused();
    _stepTimeController.text = (1 / 60).toStringAsFixed(3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _paused,
      builder: (context, value) {
        final isPaused = value.data;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Step time:'),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                textAlign: TextAlign.end,
                controller: _stepTimeController,
              ),
            ),
            IconButton(
              onPressed: (isPaused == null || !isPaused)
                  ? null
                  : () => Repository.step(stepTime: -stepTime),
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              onPressed: (isPaused == null || isPaused)
                  ? null
                  : () => _setPaused(true),
              icon: const Icon(Icons.pause),
            ),
            IconButton(
              onPressed: (isPaused == null || !isPaused)
                  ? null
                  : () => _setPaused(false),
              icon: const Icon(Icons.play_arrow),
            ),
            IconButton(
              onPressed: (isPaused == null || !isPaused)
                  ? null
                  : () => Repository.step(stepTime: stepTime),
              icon: const Icon(Icons.skip_next),
            ),
          ],
        );
      },
    );
  }

  void _setPaused(bool paused) {
    setState(() {
      _paused = Repository.setPaused(paused);
    });
  }

  @override
  void dispose() {
    _stepTimeController.dispose();
    super.dispose();
  }
}
