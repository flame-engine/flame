import 'package:flame/game.dart';
import 'package:flame_3d_example/examples/example_registry.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String _current = examples.keys.first;
  Game? _game;

  Game get game => _game ??= examples[_current]!();

  void _switchTo(String name) {
    setState(() {
      _current = name;
      _game = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(key: ValueKey(_current), game: game),
            Positioned(
              top: 8,
              left: 8,
              child: _ExamplePicker(
                examples: examples.keys.toList(),
                current: _current,
                onChanged: _switchTo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamplePicker extends StatelessWidget {
  const _ExamplePicker({
    required this.examples,
    required this.current,
    required this.onChanged,
  });

  final List<String> examples;
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: current,
        dropdownColor: Colors.black87,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        underline: const SizedBox.shrink(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        items: [
          for (final name in examples)
            DropdownMenuItem(value: name, child: Text(name)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
