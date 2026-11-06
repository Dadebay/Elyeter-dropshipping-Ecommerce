import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:elyeter/core/utils/image_compressor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('large camera image is reduced below the 1 MB limit', () {
    final image = img.Image(width: 1100, height: 1100);
    final random = Random(42);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgb(
          x,
          y,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      }
    }

    final source = Uint8List.fromList(img.encodePng(image, level: 1));
    expect(source.length, greaterThan(ImageCompressor.maxBytes));

    final compressed = ImageCompressor.compressBytes(source);
    expect(compressed, isNotNull);
    expect(compressed!.length, lessThanOrEqualTo(ImageCompressor.maxBytes));
    expect(img.decodeImage(compressed), isNotNull);
  });

  test('undecodable oversized data is rejected', () {
    final invalid = Uint8List(ImageCompressor.maxBytes + 1);
    expect(ImageCompressor.compressBytes(invalid), isNull);
  });

  test(
    'an oversized unreadable selection is never kept as the avatar',
    () async {
      final directory = await Directory.systemTemp.createTemp('avatar_test_');
      addTearDown(() => directory.delete(recursive: true));
      final selected = File('${directory.path}/broken.jpg');
      await selected.writeAsBytes(Uint8List(ImageCompressor.maxBytes + 1));

      expect(await ImageCompressor.shrink(selected.path), isNull);
    },
  );
}
