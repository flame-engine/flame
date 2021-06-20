import 'package:forge2d/forge2d.dart';

import 'body_component.dart';

class ContactTypes<T1, T2> {
  // If o1 is, or inherits from, T1 or T2
  bool has(Object o1) => o1 is T1 || o1 is T2;
  bool hasOne(Object o1, Object o2) => has(o1) || has(o2);

  // Only makes sense to call with objects that you know is in [T1, T2]
  bool inOrder(Object o1, Object o2) => o1 is T1 && o2 is T2;

  // Remember that this is not symmetric, it checks if the types in `o1` and
  // `o2` are the same or inherits from the types in `other`
  bool match(Object o1, Object o2) =>
      (o1 is T1 && o2 is T2) || (o2 is T1 && o1 is T2);
}

typedef ContactCallbackFun = void Function(Object a, Object b, Contact contact);

abstract class ContactCallback<Type1, Type2> {
  ContactTypes<Type1, Type2> types = ContactTypes<Type1, Type2>();

  void begin(Type1 a, Type2 b, Contact contact);
  void end(Type1 a, Type2 b, Contact contact);
  void preSolve(Type1 a, Type2 b, Contact contact, Manifold oldManifold) {}
  void postSolve(Type1 a, Type2 b, Contact contact, ContactImpulse impulse) {}
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

  void _maybeCallback(
    Contact contact,
    ContactCallback callback,
    ContactCallbackFun f,
  ) {
    final a = contact.fixtureA.body.userData;
    final b = contact.fixtureB.body.userData;
    final wanted = callback.types;

    if (a == null || b == null) {
      return;
    }

    if (wanted.match(a, b) ||
        (wanted.has(BodyComponent) && wanted.hasOne(a, b))) {
      wanted.inOrder(a, b) ? f(a, b, contact) : f(b, a, contact);
    }
  }

  @override
  void beginContact(Contact contact) =>
      _callbacks.forEach((c) => _maybeCallback(contact, c, c.begin));

  @override
  void endContact(Contact contact) =>
      _callbacks.forEach((c) => _maybeCallback(contact, c, c.end));

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    _callbacks.forEach((c) {
      void preSolveAux(Object a, Object b, Contact contact) {
        c.preSolve(a, b, contact, oldManifold);
      }

      _maybeCallback(contact, c, preSolveAux);
    });
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    _callbacks.forEach((c) {
      void postSolveAux(Object a, Object b, Contact contact) {
        c.postSolve(a, b, contact, impulse);
      }

      _maybeCallback(contact, c, postSolveAux);
    });
  }
}
