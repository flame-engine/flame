import 'package:jenny/src/character.dart';
import 'package:jenny/src/character_storage.dart';
import 'package:test/test.dart';

void main() {
  group('CharacterStorage', () {
    test('Should store character', () {
      final storage = CharacterStorage();

      expect(storage.isEmpty, true);

      final character = Character('Jenny');
      storage.add(character);

      expect(storage.isEmpty, false);
      expect(storage.isNotEmpty, true);

      expect(storage.contains(character.name), true);
    });

    test('Should store character aliases', () {
      final storage = CharacterStorage();
      final character = Character('Jenny', aliases: ['Jen', 'Jennifer']);
      storage.add(character);

      expect(storage.contains(character.name), true);
      expect(storage.contains(character.aliases[0]), true);
      expect(storage.contains(character.aliases[1]), true);
    });

    test('Should remove character and aliases by name', () {
      final storage = CharacterStorage();
      final character = Character('Jenny', aliases: ['Jen', 'Jennifer']);
      storage.add(character);

      expect(storage.contains(character.name), true);
      expect(storage.contains(character.aliases[0]), true);
      expect(storage.contains(character.aliases[1]), true);

      storage.remove(character.name);

      expect(storage.contains(character.name), false);
      expect(storage.contains(character.aliases[0]), false);
      expect(storage.contains(character.aliases[1]), false);
    });

    test('Should remove character and aliases by alias', () {
      final storage = CharacterStorage();
      final character = Character('Jenny', aliases: ['Jen', 'Jennifer']);
      storage.add(character);

      expect(storage.contains(character.name), true);
      expect(storage.contains(character.aliases[0]), true);
      expect(storage.contains(character.aliases[1]), true);

      storage.remove(character.aliases[1]);

      expect(storage.contains(character.name), false);
      expect(storage.contains(character.aliases[0]), false);
      expect(storage.contains(character.aliases[1]), false);
    });

    test('Should clear all characters', () {
      final storage = CharacterStorage();
      storage.add(Character('Jenny', aliases: ['Jen', 'Jennifer']));
      storage.add(Character('Thomas'));
      storage.add(Character('Leon'));

      storage.clear();

      expect(storage.isEmpty, true);
    });
  });
}
