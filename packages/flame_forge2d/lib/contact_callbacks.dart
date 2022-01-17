import 'package:forge2d/forge2d.dart';

import 'body_component.dart';

typedef ContactCallbackFun = void Function(ContactCallback a, ContactCallback b, Contact contact);

abstract class ContactCallback<Type1, Type2> {
  void begin(Type1 a, Type2 b, Contact contact);
  void end(Type1 a, Type2 b, Contact contact);
  void preSolve(Type1 a, Type2 b, Contact contact, Manifold oldManifold) {}
  void postSolve(Type1 a, Type2 b, Contact contact, ContactImpulse impulse) {}
}

class ContactCallbacks extends ContactListener {

  void _specificCallback(Contact contact, ContactCallbackFun f) {
    final a = contact.fixtureA.body.userData;
    final b = contact.fixtureB.body.userData;
    if (a == null || b == null) {
      return;
    }
    if (!(a is ContactCallback) || !(b is ContactCallback)) {
      return;
    }
    f(a, b, contact);
  }

  @override
  void beginContact(Contact contact) {
    ContactCallbackFun beginAux = (ContactCallback a, ContactCallback b, Contact contact) {
      a.begin(a, b, contact);
      b.begin(b, a, contact);
    };
    _specificCallback(contact, beginAux);
  }

  @override
  void endContact(Contact contact) {
    ContactCallbackFun endAux = (ContactCallback a, ContactCallback b, Contact contact) {
      a.end(a, b, contact);
      b.end(b, a, contact);
    };
    _specificCallback(contact, endAux);
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    ContactCallbackFun preSolveAux = (ContactCallback a, ContactCallback b, Contact contact) {
      a.preSolve(a, b, contact, oldManifold);
      b.preSolve(b, a, contact, oldManifold);
    };
    _specificCallback(contact, preSolveAux);
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    ContactCallbackFun postSolveAux = (ContactCallback a, ContactCallback b, Contact contact) {
      a.postSolve(a, b, contact, impulse);
      b.postSolve(b, a, contact, impulse);
    };
    _specificCallback(contact, postSolveAux);
  }
}
