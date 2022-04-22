import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'helpers/helpers.dart';

void main() {
  group('ContactCallbacks', () {
    late Object other;
    late Contact contact;
    late Manifold manifold;
    late ContactImpulse contactImpulse;

    setUp(() {
      other = Object();
      contact = MockContact();
      manifold = MockManifold();
      contactImpulse = MockContactImpulse();
    });

    test('beginContact calls onBeginContact', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onBeginContact = (_, __) => called++;

      contactCallbacks.beginContact(other, contact);

      expect(called, equals(1));
    });

    test('endContact calls onEndContact', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onEndContact = (_, __) => called++;

      contactCallbacks.endContact(other, contact);

      expect(called, equals(1));
    });

    test('preSolve calls onPreSolve', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onPreSolve = (_, __, ___) => called++;

      contactCallbacks.preSolve(other, contact, manifold);

      expect(called, equals(1));
    });

    test('postSolve calls on postSolve', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onPostSolve = (_, __, ___) => called++;

      contactCallbacks.postSolve(other, contact, contactImpulse);

      expect(called, equals(1));
    });
  });
}
