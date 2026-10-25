import 'package:flame/components.dart' show Anchor, Component, Vector2;

/// Builds the [InspectorSection] for a [component], or returns null when the
/// component is not of the kind this inspector is interested in.
///
/// The Inspector panel shows one section for each inspector that returns a
/// non-null section, in order.
typedef ComponentInspector = InspectorSection? Function(Component component);

/// A titled group of properties shown in the Inspector, similar to the
/// component sections of the Unity inspector.
class InspectorSection(
  final String title,
  final List<InspectorProperty<Object?>> properties,
);

/// A single value of a component, shown and possibly edited in the Inspector.
///
/// The [getValue] callback is invoked every time the Inspector refreshes, so
/// that the shown value is kept in sync with the running game. When [setValue]
/// is null, the property is read-only. The [description] is shown as the
/// tooltip of the property.
sealed class InspectorProperty<T>(
  final String label,
  final T Function() getValue, {
  final void Function(T value)? setValue,
  final String? description,
}) {
  bool get isReadOnly => setValue == null;
}

/// A floating point number. Dragging the label horizontally changes the value
/// by [step] per logical pixel.
class DoubleProperty(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
  final double step = 1.0,
  final double? min,
  final double? max,
}) extends InspectorProperty<double>;

class IntProperty(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
}) extends InspectorProperty<int>;

class BoolProperty(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
}) extends InspectorProperty<bool>;

class StringProperty(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
}) extends InspectorProperty<String>;

/// A [Vector2] value. The value passed to `setValue` is always a new vector,
/// so it is safe to keep a reference to it.
class Vector2Property(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
  final double step = 1.0,
}) extends InspectorProperty<Vector2>;

class AnchorProperty(
  super.label,
  super.getValue, {
  super.setValue,
  super.description,
}) extends InspectorProperty<Anchor>;
