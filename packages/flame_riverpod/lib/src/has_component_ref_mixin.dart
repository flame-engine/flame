import 'package:flame/components.dart';
import 'package:flame_riverpod/src/component_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin HasComponentRef on Component {
  ComponentRef get ref => _reference;
  static late ComponentRef _reference;
  static set widgetRef(WidgetRef value) => _reference = ComponentRef(value);

  final List<ProviderSubscription> _subscriptions = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T?, T) onChange, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    _subscriptions.add(
      ref.listenManual<T>(
        provider,
        (p0, p1) {
          onChange(p0, p1);
        },
        onError: onError,
      ),
    );
  }

  @override
  void onRemove() {
    for (final listener in _subscriptions) {
      listener.close();
    }
    super.onRemove();
  }
}
