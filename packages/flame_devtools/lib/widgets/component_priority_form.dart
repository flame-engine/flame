import 'package:flame_devtools/providers/component_priority_provider.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentPriorityForm extends ConsumerWidget {
  const ComponentPriorityForm({
    required this.componentId,
    super.key,
  });

  final int componentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priority = ref.watch(componentPriorityProvider(componentId));

    return priority.when(
      error: (e, s) => const Text('Error loading the component priority'),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (priority) {
        return IncrementalNumberFormField<int>(
          key: Key('priority_field_$componentId'),
          label: 'Priority',
          initialValue: priority,
          onChanged: (v) {
            Repository.setComponentAttribute(
              id: componentId,
              attribute: 'priority',
              value: v,
            );
          },
        );
      },
    );
  }
}
