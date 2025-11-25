import 'package:dashbook/dashbook.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

var _opacity = 1.0;

Widget nineTileBoxBuilderWithAnimation(DashbookContext ctx) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        children: [
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _opacity = _opacity == 1.0 ? 0.0 : 1.0;
              });
            },
            child: const Text('Toggle'),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(seconds: 2),
            opacity: _opacity,
            child: NineTileBoxWidget.asset(
              width: 400,
              height: 400,
              path: 'nine-box.png',
              tileSize: 22,
              destTileSize: 50,
              child: const Center(
                child: Text(
                  'Cool label',
                  style: TextStyle(
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
