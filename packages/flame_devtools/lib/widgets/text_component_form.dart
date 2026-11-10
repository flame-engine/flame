import 'package:flame_devtools/providers/component_text_provider.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the text of a text component, and changes the text in the running
/// game while it is edited.
class const TextComponentForm({
  required final int componentId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(componentTextProvider(componentId));

    return text.when(
      error: (e, s) => const Text('Error loading the component text'),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (text) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextFormField(
              key: Key('text_field_$componentId'),
              initialValue: text,
              onChanged: (v) {
                Repository.setComponentText(id: componentId, text: v);
              },
            ),
          ],
        );
      },
    );
  }
}
