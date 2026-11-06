import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a bundled asset without callers having to know its format.
///
/// Bitmaps go through [Image.asset] and ordinary SVGs through
/// [SvgPicture.asset]. SVGs that paint their artwork through a `<pattern>`
/// fill are handled separately: flutter_svg draws nothing for those, so the
/// bitmap inside the file is decoded and drawn here — through the pattern's
/// own transform, so only the part of the bitmap the artwork frames is shown.
class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  /// Tints the asset; only meaningful for single-color icons.
  final Color? color;

  bool get _isSvg => path.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (!_isSvg) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
      );
    }

    return FutureBuilder<_PatternArt?>(
      future: _PatternArt.of(path),
      builder: (context, snapshot) {
        final art = snapshot.data;
        if (art != null) return _sized(_paint(art));
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        return SvgPicture.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          colorFilter: color == null
              ? null
              : ColorFilter.mode(color!, BlendMode.srcIn),
        );
      },
    );
  }

  Widget _paint(_PatternArt art) => FittedBox(
    fit: fit,
    child: SizedBox(
      width: art.viewBox.width,
      height: art.viewBox.height,
      child: CustomPaint(painter: _PatternArtPainter(art, color)),
    ),
  );

  Widget _sized(Widget child) => width == null && height == null
      ? child
      : SizedBox(width: width, height: height, child: child);
}

/// Paints the bitmap through the pattern transform, clipped to the viewBox.
class _PatternArtPainter extends CustomPainter {
  const _PatternArtPainter(this.art, this.color);

  final _PatternArt art;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;
    if (color != null) {
      paint.colorFilter = ColorFilter.mode(color!, BlendMode.srcIn);
    }

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // The canvas is laid out at the viewBox's own size, so no extra fitting.
    canvas.transform(art.transform.storage);
    canvas.drawImage(art.image, Offset.zero, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PatternArtPainter oldDelegate) =>
      oldDelegate.art != art || oldDelegate.color != color;
}

/// A `<pattern>`-based SVG reduced to what it actually draws: the bitmap it
/// carries, the viewBox it is framed by, and the transform between the two.
class _PatternArt {
  const _PatternArt({
    required this.image,
    required this.viewBox,
    required this.transform,
  });

  final ui.Image image;
  final Size viewBox;

  /// Maps image pixels onto viewBox coordinates.
  final Matrix4 transform;

  static final Map<String, Future<_PatternArt?>> _cache = {};

  /// Roughly the widest the artwork is ever drawn: 120dp on a 3x screen.
  static const _targetVisiblePixels = 360.0;

  static final _viewBox = RegExp(r'viewBox="([-\d.eE\s]+)"');
  static final _box = RegExp(
    r'<rect[^>]*?width="([-\d.eE]+)"[^>]*?height="([-\d.eE]+)"',
  );
  static final _boxOrigin = RegExp(
    r'<rect[^>]*?\sx="([-\d.eE]+)"[^>]*?\sy="([-\d.eE]+)"',
  );
  static final _useTransform = RegExp(r'<use[^>]*?transform="([^"]+)"');
  static final _imageSize = RegExp(
    r'<image[^>]*?width="(\d+)"[^>]*?height="(\d+)"',
  );
  static final _dataUri = RegExp(
    r'(?:xlink:)?href="data:image/(?:png|jpe?g);base64,([^"]+)"',
  );

  static Future<_PatternArt?> of(String path) =>
      _cache.putIfAbsent(path, () => _parse(path));

  static Future<_PatternArt?> _parse(String path) async {
    final source = await rootBundle.loadString(path);
    // Plain vector SVGs are left to flutter_svg.
    if (!source.contains('<pattern')) return null;

    final data = _dataUri.firstMatch(source);
    final view = _viewBox.firstMatch(source);
    final size = _imageSize.firstMatch(source);
    final matrix = _matrix(_useTransform.firstMatch(source)?.group(1));
    if (data == null || view == null || size == null || matrix == null) {
      return null;
    }

    final numbers = view
        .group(1)!
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.tryParse)
        .toList();
    if (numbers.length != 4 || numbers.contains(null)) return null;
    final viewBox = Size(numbers[2]!, numbers[3]!);
    if (viewBox.isEmpty) return null;

    // The shape carrying the pattern fill; `objectBoundingBox` content is
    // expressed as a fraction of it. Shapes other than <rect> are rare here
    // and always cover the viewBox.
    final box = _box.firstMatch(source);
    final boxSize = box == null
        ? viewBox
        : Size(double.parse(box.group(1)!), double.parse(box.group(2)!));
    final origin = _boxOrigin.firstMatch(source);
    final boxOffset = origin == null
        ? Offset.zero
        : Offset(
            double.parse(origin.group(1)!),
            double.parse(origin.group(2)!),
          );

    final imageWidth = int.parse(size.group(1)!);

    // image pixels -> bounding box fractions -> viewBox coordinates.
    final transform = Matrix4.identity()
      ..translateByDouble(
        boxOffset.dx - numbers[0]!,
        boxOffset.dy - numbers[1]!,
        0,
        1,
      )
      ..scaleByDouble(boxSize.width, boxSize.height, 1, 1)
      ..multiply(matrix);

    // Only the slice inside the viewBox is ever visible, so decode just
    // enough resolution for that slice rather than the whole sheet.
    final drawnWidth = imageWidth * transform.entry(0, 0);
    final visible = drawnWidth <= 0
        ? imageWidth.toDouble()
        : imageWidth * viewBox.width / drawnWidth;
    final target = (imageWidth * _targetVisiblePixels / math.max(visible, 1))
        .round();

    final codec = await ui.instantiateImageCodec(
      base64Decode(data.group(1)!),
      targetWidth: target.clamp(1, imageWidth),
    );
    final frame = await codec.getNextFrame();
    return _PatternArt(
      image: frame.image,
      viewBox: viewBox,
      // Decoding smaller shrinks the pixel grid the transform was written for.
      transform: transform
        ..scaleByDouble(
          imageWidth / frame.image.width,
          imageWidth / frame.image.width,
          1,
          1,
        ),
    );
  }

  /// Parses the `matrix(...)` / `scale(...)` forms Figma exports.
  static Matrix4? _matrix(String? value) {
    if (value == null) return null;
    final match = RegExp(
      r'(matrix|scale|translate)\(([^)]*)\)',
    ).firstMatch(value);
    if (match == null) return null;
    final args = match
        .group(2)!
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.tryParse)
        .whereType<double>()
        .toList();
    switch (match.group(1)) {
      case 'matrix' when args.length == 6:
        return Matrix4(
          args[0],
          args[1],
          0,
          0, //
          args[2],
          args[3],
          0,
          0,
          0,
          0,
          1,
          0,
          args[4],
          args[5],
          0,
          1,
        );
      case 'scale' when args.isNotEmpty:
        return Matrix4.diagonal3Values(
          args[0],
          args.length > 1 ? args[1] : args[0],
          1,
        );
      case 'translate' when args.isNotEmpty:
        return Matrix4.translationValues(
          args[0],
          args.length > 1 ? args[1] : 0,
          0,
        );
      default:
        return null;
    }
  }
}
