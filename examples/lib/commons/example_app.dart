import 'package:examples/commons/example_use_case.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widgetbook/widgetbook.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final useCase = WidgetbookState.of(context).useCase;
    return MaterialApp(
      title: 'Flame Examples',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (useCase is ExampleUseCase) _ExampleBar(useCase),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ExampleBar extends StatelessWidget {
  const _ExampleBar(this.useCase);

  final ExampleUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              useCase.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Description',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog<void>(
              context: context,
              useRootNavigator: false,
              builder: (_) => _InfoDialog(useCase),
            ),
          ),
          IconButton(
            tooltip: 'See code',
            icon: const Icon(Icons.code),
            onPressed: () => launchUrl(Uri.parse(useCase.codeLink)),
          ),
        ],
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  const _InfoDialog(this.useCase);

  final ExampleUseCase useCase;

  static final _paragraphBreak = RegExp(r'\n{2,}');
  static final _lineBreak = RegExp(r'\n(?!\d+\. |[-*] )');

  /// The descriptions are written as Markdown with hard line breaks, this
  /// joins the lines of each paragraph so that the text can wrap freely.
  String get _description {
    return useCase.info
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        .trim()
        .split(_paragraphBreak)
        .map((paragraph) => paragraph.replaceAll(_lineBreak, ' '))
        .join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(useCase.name),
      content: SelectableText(_description),
      scrollable: true,
      constraints: const BoxConstraints(maxWidth: 600),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
