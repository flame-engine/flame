/// A typed key used to store and retrieve values from a [Blackboard].
///
/// Keys are compared by identity, not by [name], so declare each key once and
/// share it. Declaring it `const` is the easiest way to do that:
///
/// ```dart
/// const health = BlackboardKey<int>('health', initial: 100);
/// ```
///
/// The [name] is only used in error messages. If a key has an [initial] value,
/// reading it from a [Blackboard] that has no value for it returns that value.
class const BlackboardKey<T>(this.name, {this.initial}) {
  /// A human readable name of this key, used in error messages.
  final String name;

  /// The value returned by [Blackboard.get] if nothing was set for this key.
  final T? initial;

  /// Whether this key has an [initial] value.
  bool get hasInitial => initial != null;

  /// Whether [value] is of the type of this key.
  ///
  /// This is a runtime check that also catches what the compiler does not,
  /// because the type parameter of a key can be widened when it is passed
  /// around. For example `set(doubleKey, 0)` compiles, but stores an int.
  bool accepts(Object? value) => value is T;

  @override
  String toString() => 'BlackboardKey<$T>($name)';
}

/// Shared memory for the nodes of a behavior tree.
///
/// The blackboard is how nodes communicate with each other and with the
/// outside world. Values are accessed using a [BlackboardKey], which makes
/// every read and write type-safe.
class Blackboard() {
  final Map<BlackboardKey<Object?>, Object?> _data = {};

  /// Returns the value stored for [key].
  ///
  /// If nothing has been set, [BlackboardKey.initial] is returned. If the key
  /// has no initial value either, a [StateError] naming the key is thrown. Use
  /// [getOrNull] when the value is allowed to be missing.
  T get<T>(BlackboardKey<T> key) {
    if (_data.containsKey(key)) {
      return _data[key] as T;
    }
    if (key.hasInitial) {
      return key.initial as T;
    }
    throw StateError(
      '$key was read before being set and it has no initial value.',
    );
  }

  /// Returns the value stored for [key], or null if there is none.
  ///
  /// [BlackboardKey.initial] is used if nothing has been set.
  T? getOrNull<T>(BlackboardKey<T> key) {
    if (_data.containsKey(key)) {
      return _data[key] as T?;
    }
    return key.initial;
  }

  /// Stores [value] for [key], replacing any previous value.
  ///
  /// Throws an [ArgumentError] if [value] is not of the type of [key]. Watch
  /// out for number literals, a `BlackboardKey<double>` needs `0.0` and not
  /// `0`.
  void set<T>(BlackboardKey<T> key, T value) {
    if (!key.accepts(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Cannot be stored for $key because it is a ${value.runtimeType}.',
      );
    }
    _data[key] = value;
  }

  /// Whether a value has been explicitly set for [key].
  bool has(BlackboardKey<Object?> key) => _data.containsKey(key);

  /// Removes the value stored for [key], so that reading it falls back to
  /// [BlackboardKey.initial].
  void remove(BlackboardKey<Object?> key) => _data.remove(key);

  /// Removes all the values.
  void clear() => _data.clear();

  /// The keys that have a value set.
  Iterable<BlackboardKey<Object?>> get keys => _data.keys;

  /// Creates a shallow copy of this blackboard.
  Blackboard copy() => Blackboard().._data.addAll(_data);

  @override
  String toString() => 'Blackboard($_data)';
}
