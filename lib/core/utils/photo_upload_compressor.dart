import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Shrinks a photo to a JPEG of at most [maxBytes], for uploads.
///
/// Scales the long side down and lowers the quality step by step until the
/// file fits. Returns the original path when it already fits or cannot be
/// decoded, so the caller can still try to upload it.
Future<String> compressImageToLimit(
  String path, {
  int maxBytes = 1024 * 1024,
  int maxSide = 1600,
}) async {
  try {
    final original = File(path);
    if (await original.length() <= maxBytes && !_needsConversion(path)) {
      return path;
    }
    final bytes = await compute(
      _compress,
      _Job(await original.readAsBytes(), maxBytes, maxSide),
    );
    if (bytes == null) return path;
    final dir = await getTemporaryDirectory();
    final out = File(
      '${dir.path}/review-${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(bytes, flush: true);
    return out.path;
  } on Object {
    return path;
  }
}

bool _needsConversion(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.heic') || lower.endsWith('.heif');
}

class _Job {
  const _Job(this.bytes, this.maxBytes, this.maxSide);

  final Uint8List bytes;
  final int maxBytes;
  final int maxSide;
}

Uint8List? _compress(_Job job) {
  final decoded = img.decodeImage(job.bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  var side = job.maxSide;
  Uint8List? best;
  while (true) {
    if (image.width > side || image.height > side) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? side : null,
        height: image.height > image.width ? side : null,
        interpolation: img.Interpolation.average,
      );
    }
    for (final quality in const [85, 75, 65, 55, 45]) {
      best = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      if (best.length <= job.maxBytes) return best;
    }
    if (side <= 600) return best;
    side = (side * 0.8).round();
  }
}
