import 'package:jenny/src/localization.dart';
import 'package:test/test.dart';

void main() {
  group('Localization', () {
    test('en (English)', () {
      final plural = localizationInfo['en']!.pluralFunction;
      expect(plural(0, ['boy']), 'boys');
      expect(plural(1, ['toy']), 'toy');
      expect(plural(2, ['baby']), 'babies');
      expect(plural(3, ['man', 'men']), 'men');
    });

    test('ja (Japanese)', () {
      final plural = localizationInfo['ja']!.pluralFunction;
      expect(plural(1, ['人']), '人');
      expect(plural(2, ['人']), '人');
      expect(plural(10, ['人']), '人');
    });

    test('fr (French)', () {
      final plural = localizationInfo['fr']!.pluralFunction;
      expect(plural(0, ['ail', 'ails']), 'ail');
      expect(plural(1, ['ail', 'ails']), 'ail');
      expect(plural(2, ['ail', 'ails']), 'ails');
    });

    test('de (German)', () {
      final plural = localizationInfo['de']!.pluralFunction;
      expect(plural(0, ['Tee', 'Tees']), 'Tees');
      expect(plural(1, ['Tee', 'Tees']), 'Tee');
      expect(plural(2, ['Tee', 'Tees']), 'Tees');
    });

    test('es (Spanish)', () {
      final plural = localizationInfo['es']!.pluralFunction;
      expect(plural(-1, ['té', 'tés']), 'té');
      expect(plural(0, ['té', 'tés']), 'tés');
      expect(plural(1, ['té', 'tés']), 'té');
      expect(plural(2, ['té', 'tés']), 'tés');
    });

    test('pl (Polish)', () {
      final plural = localizationInfo['pl']!.pluralFunction;
      expect(plural(0, ['głowa', 'głowy', 'głow']), 'głow');
      expect(plural(1, ['głowa', 'głowy', 'głow']), 'głowa');
      expect(plural(2, ['głowa', 'głowy', 'głow']), 'głowy');
      expect(plural(3, ['głowa', 'głowy', 'głow']), 'głowy');
      expect(plural(4, ['głowa', 'głowy', 'głow']), 'głowy');
      expect(plural(5, ['głowa', 'głowy', 'głow']), 'głow');
      expect(plural(11, ['głowa', 'głowy', 'głow']), 'głow');
      expect(plural(21, ['głowa', 'głowy', 'głow']), 'głow');
    });

    test('uk (Ukrainian)', () {
      final plural = localizationInfo['uk']!.pluralFunction;
      expect(plural(0, ['хвиля', 'хвилі', 'хвиль']), 'хвиль');
      expect(plural(1, ['хвиля', 'хвилі', 'хвиль']), 'хвиля');
      expect(plural(2, ['хвиля', 'хвилі', 'хвиль']), 'хвилі');
      expect(plural(3, ['хвиля', 'хвилі', 'хвиль']), 'хвилі');
      expect(plural(4, ['хвиля', 'хвилі', 'хвиль']), 'хвилі');
      expect(plural(5, ['хвиля', 'хвилі', 'хвиль']), 'хвиль');
      expect(plural(10, ['хвиля', 'хвилі', 'хвиль']), 'хвиль');
      expect(plural(11, ['хвиля', 'хвилі', 'хвиль']), 'хвиль');
      expect(plural(101, ['хвиля', 'хвилі', 'хвиль']), 'хвиля');
      expect(plural(111, ['хвиля', 'хвилі', 'хвиль']), 'хвиль');
    });
  });
}
