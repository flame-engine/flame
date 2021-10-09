import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class StepScaffold extends StatelessWidget {
  final List<String> tutorial;
  final Widget game;

  const StepScaffold({
    Key? key,
    required this.tutorial,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tutorial'),
              Tab(text: 'Running example'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: tutorial.map(
                    (text) {
                      if (text.startsWith('```')) {
                        final code = text.replaceAll('```', '');
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: HighlightView(
                              code,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              language: 'dart',
                              theme: Theme.of(context).brightness == Brightness.light
                              ? githubTheme
                              : darkTheme,
                            ),
                          ),
                        );
                      } else {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: MarkdownBody(
                            data: text,
                            selectable: true,
                            extensionSet: md.ExtensionSet(
                              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                              [
                                md.EmojiSyntax(),
                                ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ).toList(),
                ),
              ),
            ),
            game,
          ],
        ),
      ),
    );
  }
}
