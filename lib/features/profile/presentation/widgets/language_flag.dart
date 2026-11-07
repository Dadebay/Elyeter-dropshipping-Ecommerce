import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The flag for a supported app language, cropped to a circle.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag({super.key, required this.languageCode, required this.semanticsLabel, this.size = 34});

  final String languageCode;
  final String semanticsLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final flagCode = switch (languageCode) {
      'tk' => 'tm',
      'ru' => 'ru',
      _ => 'gb',
    };

    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/images/flags/$flagCode.svg',
          fit: BoxFit.cover,
          // semanticsLabel: semanticsLabel,
        ),
      ),
    );
  }
}
