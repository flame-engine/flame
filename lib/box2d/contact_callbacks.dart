import 'package:box2d_flame/box2d.dart';
import 'package:flame/box2d/box2d_component.dart';

class ContactTypes {
  final Type type1, type2;

  ContactTypes(this.type1, this.type2);

  bool has(Type type) => type1 == type || type2 == type;

  // If it contains at least one type from the other ContactTypes
  bool hasOneIn(ContactTypes other) => has(other.type1) || has(other.type2);

  bool equals(ContactTypes other) =>
      (type1 == other.type1 && type2 == other.type2) ||
          (type2 == other.type1 && type1 == other.type2);
}

mixin ContactCallback<Type1, Type2> {
  ContactTypes types;

  void begin(Type1 a, Type2 b, Contact contact);
  void end(Type1 a, Type2 b, Contact contact);
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
      c.types.type1 == a.runtimeType;

  void _maybeCallback(Contact contact, ContactCallback callback, Function f) {
    final Object a = contact.fixtureA.userData;
    final Object b = contact.fixtureB.userData;
    final ContactTypes current = ContactTypes(a.runtimeType, b.runtimeType);
    final ContactTypes wanted = callback.types;

    if (current.equals(wanted) || (wanted.has(BodyComponent) && current.hasOneIn(wanted))) {
      _inOrder(callback, a, b) ? f(a, b, contact) : f(b, a, contact);
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
