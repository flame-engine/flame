import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

img.Image _image(int width, int height, {int r = 0, int g = 0, int b = 0}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return image;
}

void main() {
  group('diffImages', () {
    test('reports identical images', () {
      final result = diffImages(_image(4, 4), _image(4, 4));

      expect(result.differingPixels, 0);
      expect(result.bounds, isNull);
      expect(result.summary, 'The images are identical.');
    });

    test('counts the differing pixels and their bounds', () {
      final after = _image(10, 10)
        ..setPixelRgb(2, 3, 255, 255, 255)
        ..setPixelRgb(5, 6, 255, 255, 255);

      final result = diffImages(_image(10, 10), after);

      expect(result.differingPixels, 2);
      expect(result.totalPixels, 100);
      expect(result.bounds, (left: 2, top: 3, width: 4, height: 4));
      expect(
        result.summary,
        '2.00% of the pixels differ (2 of 100), within the rectangle 2,3 of '
        'size 4x4.',
      );
      expect(result.image.getPixel(2, 3).r, 255);
      expect(result.image.getPixel(2, 3).g, 0);
      expect(result.image.getPixel(0, 0).r, result.image.getPixel(0, 0).g);
    });

    test('ignores differences within the threshold', () {
      final after = _image(2, 2, r: 10);

      expect(diffImages(_image(2, 2), after, threshold: 10).differingPixels, 0);
      expect(diffImages(_image(2, 2), after, threshold: 9).differingPixels, 4);
    });
  });

  group('diff command', () {
    late Directory directory;
    late StringBuffer out;
    late StringBuffer err;
    late FlameCommandRunner runner;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('flame_cli_test');
      out = StringBuffer();
      err = StringBuffer();
      runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: directory,
      );
      File(
        p.join(directory.path, 'a.png'),
      ).writeAsBytesSync(img.encodePng(_image(4, 4)));
      File(
        p.join(directory.path, 'b.png'),
      ).writeAsBytesSync(img.encodePng(_image(4, 4, r: 255)));
      File(
        p.join(directory.path, 'small.png'),
      ).writeAsBytesSync(img.encodePng(_image(2, 2)));
      File(p.join(directory.path, 'text.png')).writeAsStringSync('no');
    });

    tearDown(() => directory.deleteSync(recursive: true));

    test('compares the images and writes the diff image', () async {
      final exitCode = await runner.run([
        'diff',
        'a.png',
        'b.png',
        '--output',
        'diff.png',
      ]);

      expect(exitCode, ExitCodes.success);
      expect(out.toString(), contains('100.00% of the pixels differ'));
      final diff = img.decodePng(
        File(p.join(directory.path, 'diff.png')).readAsBytesSync(),
      );
      expect(diff!.getPixel(0, 0).r, 255);
    });

    test('exits with 1 for different images when asked', () async {
      expect(await runner.run(['diff', 'a.png', 'b.png', '--exit-code']), 1);
      expect(await runner.run(['diff', 'a.png', 'a.png', '--exit-code']), 0);
    });

    test('rejects images of different sizes', () async {
      expect(await runner.run(['diff', 'a.png', 'small.png']), ExitCodes.data);
      expect(err.toString(), contains('different sizes: 4x4 and 2x2'));
    });

    test('rejects files that are not PNG images', () async {
      expect(await runner.run(['diff', 'a.png', 'text.png']), ExitCodes.data);
      expect(err.toString(), contains('is not a PNG image'));
    });

    test('reports missing files', () async {
      expect(await runner.run(['diff', 'a.png', 'nope.png']), ExitCodes.data);
      expect(err.toString(), contains('Could not read'));
    });

    test('validates the arguments', () async {
      expect(await runner.run(['diff', 'a.png']), ExitCodes.usage);
      expect(
        await runner.run(['diff', 'a.png', 'b.png', '-t', '300']),
        ExitCodes.usage,
      );
    });
  });
}
