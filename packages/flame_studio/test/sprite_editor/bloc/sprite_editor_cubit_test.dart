import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/sprite_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockComponentRepository() extends Mock implements ComponentRepository;

void main() {
  group(SpriteEditorCubit, () {
    const project = Project(path: '/game');
    const image = 'assets/images/a.png';
    const other = 'assets/images/b.png';
    final bytes = Uint8List.fromList([1, 2, 3]);

    late ComponentRepository repository;

    setUp(() {
      repository = _MockComponentRepository();
      when(() => repository.getImages(project.path))
          .thenAnswer((_) async => const [image, other]);
      when(() => repository.readImage(project.path, any()))
          .thenAnswer((_) async => bytes);
    });

    SpriteEditorCubit build([
      ComponentSprite sprite = const ComponentSprite(),
    ]) {
      return SpriteEditorCubit(
        project: project,
        sprite: sprite,
        componentRepository: repository,
      );
    }

    const region = ComponentSprite(
      image: image,
      srcPosition: ComponentPosition(x: 10, y: 20),
      srcSize: ComponentSize(width: 8, height: 4),
    );

    test('started lists the images and reads the image in use', () async {
      final cubit = build(region);
      await cubit.started();

      expect(cubit.state.status, equals(SpriteEditorStatus.ready));
      expect(cubit.state.images, equals([image, other]));
      expect(cubit.state.bytes, equals(bytes));
    });

    test('started reports images that cannot be listed', () async {
      when(() => repository.getImages(project.path)).thenThrow(Exception());
      final cubit = build();
      await cubit.started();

      expect(cubit.state.status, equals(SpriteEditorStatus.failure));
    });

    test('started marks an image that cannot be read as invalid', () async {
      when(() => repository.readImage(project.path, image))
          .thenThrow(Exception());
      final cubit = build(region);
      await cubit.started();

      expect(cubit.state.isImageInvalid, isTrue);
      expect(cubit.state.canApply, isFalse);
    });

    test('keeps the region it opened with when it fits the image', () async {
      final cubit = build(region);
      await cubit.started();
      cubit.imageDecoded(64, 64);

      expect(cubit.state.sprite, equals(region));
      expect(cubit.state.canApply, isTrue);
    });

    test('fits the region it opened with inside a smaller image', () async {
      final cubit = build(region);
      await cubit.started();
      cubit.imageDecoded(12, 2);

      expect(
        cubit.state.sprite,
        equals(
          const ComponentSprite(
            image: image,
            srcPosition: ComponentPosition(x: 4),
            srcSize: ComponentSize(width: 8, height: 2),
          ),
        ),
      );
    });

    test('a selected image starts fully selected', () async {
      final cubit = build(region);
      await cubit.started();
      cubit
        ..imageDecoded(64, 64)
        ..zoomedIn()
        ..panned(5, 5);

      await cubit.imageSelected(other);
      expect(cubit.state.canApply, isFalse);
      expect(cubit.state.zoom, equals(1));
      expect(cubit.state.panX, equals(0));

      cubit.imageDecoded(32, 16);
      expect(
        cubit.state.sprite,
        equals(
          const ComponentSprite(
            image: other,
            srcSize: ComponentSize(width: 32, height: 16),
          ),
        ),
      );
    });

    test('selecting the image in use keeps the region', () async {
      final cubit = build(region);
      await cubit.started();
      cubit.imageDecoded(64, 64);

      await cubit.imageSelected(image);

      expect(cubit.state.sprite, equals(region));
      expect(cubit.state.canApply, isTrue);
    });

    test('ignores an image read after another was selected', () async {
      final cubit = build();
      final pending = cubit.imageSelected(image);
      when(() => repository.readImage(project.path, other))
          .thenAnswer((_) async => Uint8List.fromList([9]));
      await cubit.imageSelected(other);
      await pending;

      expect(cubit.state.sprite.image, equals(other));
      expect(cubit.state.bytes, equals(Uint8List.fromList([9])));
    });

    blocTest<SpriteEditorCubit, SpriteEditorState>(
      'imageFailed marks the image as invalid',
      build: build,
      act: (cubit) => cubit.imageFailed(),
      verify: (cubit) => expect(cubit.state.isImageInvalid, isTrue),
    );

    test('regionChanged is ignored until the image is decoded', () {
      final cubit = build(region)..regionChanged(1, 1, 1, 1);

      expect(cubit.state.sprite, equals(region));
    });

    test('regionChanged rounds to pixels and stays in the image', () {
      final cubit = build(region)
        ..imageDecoded(64, 32)
        ..regionChanged(1.4, 2.6, 3.5, 0);

      expect(
        cubit.state.sprite,
        equals(
          const ComponentSprite(
            image: image,
            srcPosition: ComponentPosition(x: 1, y: 3),
            srcSize: ComponentSize(width: 4, height: 1),
          ),
        ),
      );

      cubit.regionChanged(-5, 100, 200, 8);
      expect(
        cubit.state.sprite,
        equals(
          const ComponentSprite(
            image: image,
            srcPosition: ComponentPosition(y: 24),
            srcSize: ComponentSize(width: 64, height: 8),
          ),
        ),
      );
    });

    test('regionMoved keeps the size at the sides of the image', () {
      final cubit = build(region)
        ..imageDecoded(64, 64)
        ..regionMoved(100, 3);

      expect(cubit.state.sprite.srcSize, equals(region.srcSize));
      expect(
        cubit.state.sprite.srcPosition,
        equals(const ComponentPosition(x: 56, y: 3)),
      );
    });

    test('zooms through the levels, and reset also resets the scroll', () {
      final cubit = build()
        ..zoomedIn()
        ..panned(3, 4)
        ..panned(1, 1);
      expect(cubit.state.zoom, greaterThan(1));
      expect(cubit.state.panX, equals(4));
      expect(cubit.state.panY, equals(5));

      cubit
        ..zoomedOut()
        ..zoomedOut();
      expect(cubit.state.zoom, lessThan(1));
      expect(cubit.state.canZoomIn, isTrue);
      expect(cubit.state.canZoomOut, isTrue);

      cubit.zoomReset();
      expect(cubit.state.zoom, equals(1));
      expect(cubit.state.panX, equals(0));
    });
  });
}
