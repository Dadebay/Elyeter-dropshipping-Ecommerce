import 'package:flutter/material.dart';

/// Marks a search navigation that starts from a screen's app bar button.
/// Kept so callers can still pass their button bounds; the search page itself
/// now opens with a plain, quick fade.
class SearchButtonOrigin {
  const SearchButtonOrigin(this.bounds);

  final Rect bounds;
}

/// Calm entrance for the search page: a short fade, nothing moving, resizing
/// or casting shadows while the customer is about to type.
class SearchFadeTransition extends StatelessWidget {
  const SearchFadeTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  static const duration = Duration(milliseconds: 180);
  static const reverseDuration = Duration(milliseconds: 140);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}
