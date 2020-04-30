import 'package:box2d_flame/box2d.dart';

mixin ContactCallback {
  List<Type> objects;

  void begin(Object a, Object b);
  void end(Object a, Object b);
}

class ContactCallbacks extends ContactListener {
  final List<ContactCallback> _callbacks = [];

  void register(ContactCallback callback) {
    _callbacks.add(callback);
  }

  void deregister(ContactCallback callback) {
    _callbacks.remove(callback);
  }

  void clear() {
    _callbacks.clear();
  }

  bool _inOrder(ContactCallback c, Object a, Object b) =>
      c.objects.indexOf(a.runtimeType) < c.objects.indexOf(b.runtimeType);

  void _maybeCallback(Contact contact, ContactCallback callback, Function f) {
    final Object a = contact.fixtureA.userData;
    final Object b = contact.fixtureB.userData;
    final Set<Type> current = {a.runtimeType, b.runtimeType};
    final Set<Type> wanted = callback.objects.toSet();

    if (current.containsAll(wanted) && wanted.containsAll(current)) {
      _inOrder(callback, a, b) ? f(a, b) : f(b, a);
    } else if (wanted.contains(AnyObject) &&
        current.intersection(wanted.toSet()).isNotEmpty) {
      !_inOrder(callback, a, b) ? f(a, b) : f(b, a);
    }
  }

  @override
  void beginContact(Contact contact) =>
      _callbacks.forEach((c) => _maybeCallback(contact, c, c.begin));

  @override
  void endContact(Contact contact) =>
      _callbacks.forEach((c) => _maybeCallback(contact, c, c.end));

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}

// Used to handle collision with bodies of any other type
class AnyObject {}
