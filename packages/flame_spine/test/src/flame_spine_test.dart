import 'package:flame_spine/flame_spine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('can load skeleton', () async {
    final skeleton = await loadSkeleton('spineboy');

    expect(skeleton, isA<SkeletonAnimation>());
    expect(skeleton, isNotNull);
  });

  test('can load animations', () async {
    final animation = await loadAnimations('spineboy');

    expect(animation, isA<List<String>>());
    expect(animation, isNotNull);
    expect(animation.length, equals(7));
  });
}
