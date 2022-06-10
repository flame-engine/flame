import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dark.dart';
import 'package:flutter_highlight/themes/github.dart';

class CodeBlock extends StatelessWidget {
  final String value;

  const CodeBlock({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final code = value.replaceAll('```', '');
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: HighlightView(
              code,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              language: 'dart',
              theme: Theme.of(context).brightness == Brightness.light
                  ? githubTheme
                  : darkTheme,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: code),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code copied!'),
                  ),
                );
              },
              tooltip: 'Copy code',
              icon: const Icon(Icons.copy),
            ),
          )
        ],
      ),
    );
  }
}
