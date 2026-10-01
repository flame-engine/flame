import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class const DebugModeButton({super.key, final int? id}) extends StatefulWidget {
  @override
  State<DebugModeButton> createState() => _DebugModeButtonState();
}

class _DebugModeButtonState() extends State<DebugModeButton> {
  late Future<bool> _debugMode;

  @override
  void initState() {
    super.initState();
    _debugMode = Repository.getDebugMode(id: widget.id);
  }

  @override
  void didUpdateWidget(DebugModeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _debugMode = Repository.getDebugMode(id: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _debugMode,
      builder: (context, value) {
        final buttonPrefix = switch (value.data) {
          null => 'Loading',
          true => 'Disable',
          false => 'Enable',
        };

        return ElevatedButton(
          onPressed: value.data == null
              ? null
              : () {
                  setState(() {
                    _debugMode = Repository.swapDebugMode(id: widget.id);
                  });
                },
          child: Text('$buttonPrefix Debug Mode'),
        );
      },
    );
  }
}
