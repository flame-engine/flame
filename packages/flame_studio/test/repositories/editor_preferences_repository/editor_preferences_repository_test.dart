import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKeyValueStorageClient()
    extends Mock
    implements KeyValueStorageClient;

void main() {
  group(EditorPreferencesRepository, () {
    const projectPath = '/projects/game';
    const componentName = 'player';
    final key = EditorPreferencesRepository.componentZoomKey(
      projectPath,
      componentName,
    );

    late KeyValueStorageClient storage;
    late EditorPreferencesRepository repository;

    setUp(() {
      storage = _MockKeyValueStorageClient();
      repository = EditorPreferencesRepository(storage: storage);

      when(() => storage.write(any(), any())).thenAnswer((_) async {});
    });

    test('componentZoomKey differs per project and component', () {
      expect({
        EditorPreferencesRepository.componentZoomKey('/a', 'player'),
        EditorPreferencesRepository.componentZoomKey('/b', 'player'),
        EditorPreferencesRepository.componentZoomKey('/a', 'enemy'),
      }, hasLength(3));
    });

    group('getComponentZoom', () {
      Future<double> get() => repository.getComponentZoom(
        projectPath: projectPath,
        componentName: componentName,
      );

      test('returns the default zoom when nothing is stored', () async {
        when(() => storage.read(key)).thenAnswer((_) async => null);

        expect(await get(), EditorPreferencesRepository.defaultZoom);
      });

      test('returns the stored zoom', () async {
        when(() => storage.read(key)).thenAnswer((_) async => '2.5');

        expect(await get(), 2.5);
      });

      test(
        'returns the default zoom when the stored value is unreadable',
        () async {
          when(() => storage.read(key)).thenAnswer((_) async => 'big');

          expect(await get(), EditorPreferencesRepository.defaultZoom);
        },
      );

      test(
        'returns the default zoom when the stored value is not finite',
        () async {
          when(() => storage.read(key)).thenAnswer((_) async => 'NaN');

          expect(await get(), EditorPreferencesRepository.defaultZoom);
        },
      );

      test('clamps the stored zoom', () async {
        when(() => storage.read(key)).thenAnswer((_) async => '100');
        expect(await get(), EditorPreferencesRepository.maxZoom);

        when(() => storage.read(key)).thenAnswer((_) async => '0');
        expect(await get(), EditorPreferencesRepository.minZoom);
      });
    });

    group('setComponentZoom', () {
      test('stores the zoom under the component key', () async {
        await repository.setComponentZoom(
          projectPath: projectPath,
          componentName: componentName,
          zoom: 1.5,
        );

        verify(() => storage.write(key, '1.5')).called(1);
      });

      test('clamps the zoom', () async {
        await repository.setComponentZoom(
          projectPath: projectPath,
          componentName: componentName,
          zoom: 50,
        );

        verify(
          () => storage.write(
            key,
            EditorPreferencesRepository.maxZoom.toString(),
          ),
        ).called(1);
      });
    });
  });
}
