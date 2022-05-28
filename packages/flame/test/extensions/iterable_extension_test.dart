import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('IterableExtension', () {
    test('indexedMap<int, int>', () {
      final src = [3, 7, 12, -1];
      final out = src.indexedMap((i, e) => i + e).toList();
      expect(out, [3 + 0, 7 + 1, 12 + 2, -1 + 3]);
    });

    test('indexedMap<str, str>', () {
      final src = ['a', 'b', 'c', 'd', 'e', 'f'];
      final out = src.indexedMap((i, e) => e * i).toList();
      expect(out, ['', 'b', 'cc', 'ddd', 'eeee', 'fffff']);
    });

    test('indexedMap<int, double>', () {
      final src = <int>[0, 1, 2, 3, 4, 5];
      final out = src.indexedMap((i, e) => e.toDouble() / (i + 1));
      expect(out, [0, 1 / 2, 2 / 3, 3 / 4, 4 / 5, 5 / 6]);
    });

    test('indexedMap properties', () {
      final src = [3, 7, 12, -11];
      final out = src.indexedMap((i, e) => i + e);
      expect(out.isEmpty, false);
      expect(out.length, 4);
      expect(out.first, src.first + 0);
      expect(out.last, src.last + 3);
      expect(out.elementAt(1), src[1] + 1);
    });

    test('indexedMap.single', () {
      final src = ['Flame'];
      final out = src.indexedMap((index, e) => '$e:$index');
      expect(out.single, 'Flame:0');
    });
  });
}
