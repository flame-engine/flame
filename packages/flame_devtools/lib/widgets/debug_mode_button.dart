import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class DebugModeButton extends StatefulWidget {
  const DebugModeButton({super.key, this.id});

  final int? id;

  @override
  Key? get key => super.key ?? ValueKey(id);

  @override
  State<DebugModeButton> createState() => _DebugModeButtonState();
}

class _DebugModeButtonState extends State<DebugModeButton> {
  Future<bool>? _debugMode;

  @override
  void initState() {
    _debugMode = Repository.getDebugMode(id: widget.id);
    super.initState();
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
                  setState(
                    () {
                      _debugMode = Repository.swapDebugMode(id: widget.id);
                    },
                  );
                },
          child: Text('$buttonPrefix Debug Mode'),
        );
      },
    );
  }
}
