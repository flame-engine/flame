import 'dart:ui';

import 'package:flame_tiled/src/rectangle_bin_packer.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RectangleBinPacker', () {
    late RectangleBinPacker bin;
    setUp(() {
      bin = RectangleBinPacker(1024, 1024);
    });

    test('asserts oversized requests', () {
      expect(() => bin.pack(bin.maxX + 1, bin.maxY), throwsAssertionError);
      expect(() => bin.pack(bin.maxX, bin.maxY + 1), throwsAssertionError);
      expect(bin.bins, hasLength(1));
      expect(bin.bins.first.top, 0);
      expect(bin.bins.first.left, 0);
      expect(bin.bins.first.width, bin.maxX);
      expect(bin.bins.first.height, bin.maxY);
    });

    test('handles full request', () {
      expect(
        bin.pack(bin.maxX, bin.maxY),
        Rect.fromLTWH(
          0,
          0,
          bin.maxX,
          bin.maxY,
        ),
      );
      expect(bin.bins, hasLength(0));
    });

    test('bifurcates with one bottom bin when rect is full width', () {
      expect(
        bin.pack(bin.maxX, 10),
        Rect.fromLTWH(
          0,
          0,
          bin.maxX,
          10,
        ),
      );
      expect(bin.bins, hasLength(1));
      expect(bin.bins.first.top, 10);
      expect(bin.bins.first.left, 0);
      expect(bin.bins.first.width, bin.maxX);
      expect(bin.bins.first.height, bin.maxY - 10);
    });

    test('bifurcates with one right bin when rect is full width', () {
      expect(
        bin.pack(10, bin.maxY),
        Rect.fromLTWH(
          0,
          0,
          10,
          bin.maxY,
        ),
      );
      expect(bin.bins, hasLength(1));
      expect(bin.bins.first.top, 0);
      expect(bin.bins.first.left, 10);
      expect(bin.bins.first.width, bin.maxX - 10);
      expect(bin.bins.first.height, bin.maxY);
    });

    test('sanity check', () {
      final colCount = bin.maxX ~/ 512;
      final rowCount = bin.maxY ~/ 256;
      for (var y = 0; y < rowCount; y++) {
        for (var x = 0; x < colCount; x++) {
          expect(bin.pack(512, 256), isNot(Rect.zero));
        }
      }
      expect(bin.bins, isEmpty, reason: 'filled up atlas');
    });
  });
}
