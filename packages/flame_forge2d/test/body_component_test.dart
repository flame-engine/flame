import 'package:flame_forge2d/body_component.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class TestBodyComponent extends BodyComponent {
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BodyComponent', () {
    group('renderBody', () {
      test('is true by default', () {
        final body = TestBodyComponent();
        expect(body.renderBody, isTrue);
      });

      test('sets and gets', () {
        final body = TestBodyComponent()..renderBody = false;
        expect(body.renderBody, isFalse);
      });
    });
  });
}
