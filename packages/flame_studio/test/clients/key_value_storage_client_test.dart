import 'package:flame_studio/clients/clients.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferencesAsync()
    extends Mock
    implements SharedPreferencesAsync;

void main() {
  group(KeyValueStorageClient, () {
    late SharedPreferencesAsync preferences;
    late KeyValueStorageClient client;

    setUp(() {
      preferences = _MockSharedPreferencesAsync();
      client = KeyValueStorageClient(preferences: preferences);
    });

    group('read', () {
      test('returns the stored value', () async {
        when(() => preferences.getString('key')).thenAnswer((_) async => 'v');

        expect(await client.read('key'), equals('v'));
      });

      test('returns null when nothing is stored', () async {
        when(() => preferences.getString('key')).thenAnswer((_) async => null);

        expect(await client.read('key'), isNull);
      });
    });

    group('write', () {
      test('stores the value', () async {
        when(() => preferences.setString('key', 'v')).thenAnswer((_) async {});

        await client.write('key', 'v');

        verify(() => preferences.setString('key', 'v')).called(1);
      });
    });
  });
}
