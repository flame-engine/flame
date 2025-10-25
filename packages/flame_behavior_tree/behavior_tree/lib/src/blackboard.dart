/// Shared memory for behavior tree nodes to read and write data.
///
/// The Blackboard provides a centralized location for storing and retrieving
/// data that needs to be shared between nodes in a behavior tree.
class Blackboard {
  final Map<String, dynamic> _data = {};

  /// Gets a value from the blackboard.
  ///
  /// Returns the value associated with [key], or [defaultValue] if the key
  /// doesn't exist. If no default is provided and the key doesn't exist,
  /// throws a [StateError].
  T get<T>(String key, {T? defaultValue}) {
    if (!_data.containsKey(key)) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw StateError('Key "$key" not found in blackboard');
    }
    return _data[key] as T;
  }

  /// Sets a value in the blackboard.
  ///
  /// Associates [value] with [key]. If [key] already exists, its value is
  /// replaced.
  void set<T>(String key, T value) {
    _data[key] = value;
  }

  /// Checks if a key exists in the blackboard.
  bool has(String key) => _data.containsKey(key);

  /// Removes a key and its value from the blackboard.
  ///
  /// Returns the value that was associated with [key], or null if [key]
  /// was not in the blackboard.
  dynamic remove(String key) => _data.remove(key);

  /// Removes all entries from the blackboard.
  void clear() => _data.clear();

  /// Returns all keys in the blackboard.
  Iterable<String> get keys => _data.keys;

  /// Returns the number of key-value pairs in the blackboard.
  int get length => _data.length;

  /// Returns true if the blackboard is empty.
  bool get isEmpty => _data.isEmpty;

  /// Returns true if the blackboard is not empty.
  bool get isNotEmpty => _data.isNotEmpty;

  /// Creates a copy of this blackboard.
  Blackboard copy() {
    final copy = Blackboard();
    copy._data.addAll(_data);
    return copy;
  }

  @override
  String toString() {
    return 'Blackboard($_data)';
  }
}
