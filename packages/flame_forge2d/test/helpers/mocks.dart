import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:mocktail/mocktail.dart';

class MockContactCallback extends Mock implements ContactCallbacks {}

class MockContact extends Mock implements Contact {}

class MockBody extends Mock implements Body {}

class MockFixture extends Mock implements Fixture {}

class MockManifold extends Mock implements Manifold {}

class MockContactImpulse extends Mock implements ContactImpulse {}
