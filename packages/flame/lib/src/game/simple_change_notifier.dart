import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flutter/foundation.dart';

/// A lightweight [Listenable] implementation optimized for objects that are
/// mutated many times per frame and that usually have a single listener, such
/// as [NotifyingVector2] and [Transform2D].
///
/// Compared to Flutter's [ChangeNotifier] this class:
/// - keeps the first listener in a plain field, so notifying it is a single
///   null check and a call, and only allocates a list when a second listener
///   is added;
/// - does not catch exceptions thrown by listeners. An exception propagates
///   to the code that performed the mutation, the same as for any other
///   callback in Flame;
/// - does not participate in Flutter's memory allocation tracking and has no
///   disposed state.
///
/// Listeners that are added while a notification is being dispatched are not
/// invoked during that notification, and listeners that are removed while a
/// notification is being dispatched are not invoked either, mirroring the
/// guarantees of [ChangeNotifier].
mixin class SimpleChangeNotifier implements Listenable {
  VoidCallback? _listener;
  List<VoidCallback?>? _extraListeners;
  int _notificationDepth = 0;
  bool _hasRemovedListeners = false;

  /// Whether any listeners are currently registered.
  @protected
  bool get hasListeners {
    if (_listener != null) {
      return true;
    }
    final extraListeners = _extraListeners;
    if (extraListeners == null) {
      return false;
    }
    for (final listener in extraListeners) {
      if (listener != null) {
        return true;
      }
    }
    return false;
  }

  @override
  void addListener(VoidCallback listener) {
    if (_listener == null && _extraListeners == null) {
      _listener = listener;
    } else {
      (_extraListeners ??= <VoidCallback?>[]).add(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_listener == listener) {
      _listener = null;
      _hasRemovedListeners = true;
    } else {
      final extraListeners = _extraListeners;
      if (extraListeners != null) {
        final index = extraListeners.indexOf(listener);
        if (index >= 0) {
          extraListeners[index] = null;
          _hasRemovedListeners = true;
        }
      }
    }
    if (_notificationDepth == 0) {
      _compact();
    }
  }

  /// Removes all listeners. The object can still be used afterwards, but
  /// nobody will be notified of changes until new listeners are added.
  @mustCallSuper
  void dispose() {
    _listener = null;
    _extraListeners = null;
    _hasRemovedListeners = false;
  }

  /// Calls all the registered listeners.
  @protected
  @visibleForTesting
  void notifyListeners() {
    final extraListeners = _extraListeners;
    if (extraListeners == null) {
      _listener?.call();
      return;
    }
    _notifyAll(extraListeners);
  }

  void _notifyAll(List<VoidCallback?> extraListeners) {
    _notificationDepth++;
    _listener?.call();
    final end = extraListeners.length;
    for (var i = 0; i < end; i++) {
      extraListeners[i]?.call();
    }
    _notificationDepth--;
    if (_notificationDepth == 0 && _hasRemovedListeners) {
      _compact();
    }
  }

  void _compact() {
    _hasRemovedListeners = false;
    final extraListeners = _extraListeners;
    if (extraListeners == null) {
      return;
    }
    extraListeners.removeWhere((listener) => listener == null);
    if (_listener == null && extraListeners.isNotEmpty) {
      _listener = extraListeners.removeAt(0);
    }
    if (extraListeners.isEmpty) {
      _extraListeners = null;
    }
  }
}
