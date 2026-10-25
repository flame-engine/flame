import 'dart:async';

import 'package:flame/components.dart' show Component;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/inspector/component_inspectors.dart';
import 'package:flame_studio/src/core/inspector/inspector_property.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/common/disclosure_triangle.dart';
import 'package:flame_studio/src/widgets/common/studio_text_field.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flame_studio/src/widgets/panels/inspector/property_editors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the properties of the selected component, grouped into sections.
///
/// The view refreshes periodically so that the values follow the running
/// game.
class const InspectorView({super.key}) extends ConsumerStatefulWidget {
  static const Duration refreshFrequency = Duration(milliseconds: 100);

  @override
  ConsumerState<InspectorView> createState() => _InspectorViewState();
}

class _InspectorViewState() extends ConsumerState<InspectorView> {
  late final Timer _timer;
  final Set<String> _collapsedSections = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(InspectorView.refreshFrequency, (_) {
      if (ref.read(selectedComponentProvider) != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final component = ref.watch(selectedComponentProvider);
    if (component == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select a component in the Hierarchy to inspect it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.dimTextColor),
          ),
        ),
      );
    }

    final sections = [
      for (final inspector in ref.watch(componentInspectorsProvider))
        ?inspector(component),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(component),
        for (final section in sections) ...[
          _SectionHeader(
            section.title,
            isCollapsed: _collapsedSections.contains(section.title),
            onTap: () => setState(() {
              if (!_collapsedSections.remove(section.title)) {
                _collapsedSections.add(section.title);
              }
            }),
          ),
          if (!_collapsedSections.contains(section.title))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  for (final property in section.properties)
                    _PropertyRow(property),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class const _Header(final Component component) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              component.runtimeType.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.fontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StudioTooltip(
            message:
                'The identity hash code of the component, which tells apart '
                'components of the same type',
            child: Text(
              '#${component.hashCode.toRadixString(16)}',
              style: TextStyle(color: theme.dimTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

class const _SectionHeader(
  final String title, {
  required final bool isCollapsed,
  required final VoidCallback onTap,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: theme.rowHeight,
          color: theme.sectionHeaderColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              DisclosureTriangle(
                isExpanded: !isCollapsed,
                color: theme.dimTextColor,
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps the setter of a property, so that the game is repainted after each
/// edit.
typedef _EditCallback = ValueChanged<T>? Function<T>(ValueChanged<T>? setValue);

class const _PropertyRow(final InspectorProperty<Object?> property)
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    ValueChanged<T>? edit<T>(ValueChanged<T>? setValue) {
      if (setValue == null) {
        return null;
      }
      return (value) {
        setValue(value);
        gameController.repaint();
      };
    }

    // The properties are matched by their concrete type, so that their
    // callbacks are accessed with the precise type of their values.
    final (ValueChanged<double>? onDrag, Widget editor) = switch (property) {
      final DoubleProperty p => _doubleEditor(p, edit),
      final IntProperty p => _intEditor(p, edit),
      final BoolProperty p => (
        null,
        StudioCheckbox(value: p.getValue(), onChanged: edit(p.setValue)),
      ),
      final StringProperty p => (
        null,
        p.setValue == null
            ? ReadOnlyValue(p.getValue())
            : StudioTextField(
                value: p.getValue(),
                onSubmitted: edit(p.setValue),
              ),
      ),
      final Vector2Property p => (
        null,
        Vector2Field(p.getValue(), onChanged: edit(p.setValue), step: p.step),
      ),
      final AnchorProperty p => (
        null,
        AnchorPicker(p.getValue(), onChanged: edit(p.setValue)),
      ),
    };

    return SizedBox(
      height: theme.rowHeight + 2,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ScrubLabel(
              property.label,
              onDrag: onDrag,
              tooltip: _tooltip(
                property.description,
                isDraggable: onDrag != null,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(flex: 3, child: editor),
        ],
      ),
    );
  }

  static String? _tooltip(String? description, {required bool isDraggable}) {
    if (!isDraggable) {
      return description;
    }
    const hint = 'Drag the label sideways to change the value.';
    return description == null ? hint : '$description.\n$hint';
  }

  static (ValueChanged<double>?, Widget) _doubleEditor(
    DoubleProperty p,
    _EditCallback edit,
  ) {
    final setValue = edit(p.setValue);
    if (setValue == null) {
      return (null, NumberField(p.getValue()));
    }
    void set(double value) {
      setValue(
        value.clamp(p.min ?? double.negativeInfinity, p.max ?? double.infinity),
      );
    }

    return (
      (dx) => set(p.getValue() + dx * p.step),
      NumberField(p.getValue(), onSubmitted: set),
    );
  }

  static (ValueChanged<double>?, Widget) _intEditor(
    IntProperty p,
    _EditCallback edit,
  ) {
    final setValue = edit(p.setValue);
    final value = p.getValue().toDouble();
    if (setValue == null) {
      return (null, NumberField(value, isInteger: true));
    }
    return (
      // Dragging changes the value by one for every 4 logical pixels.
      (dx) => setValue(p.getValue() + (dx / 4).round()),
      NumberField(
        value,
        isInteger: true,
        onSubmitted: (value) => setValue(value.round()),
      ),
    );
  }
}
