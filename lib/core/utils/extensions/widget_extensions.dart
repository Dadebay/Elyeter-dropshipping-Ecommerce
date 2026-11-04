import 'package:flutter/widgets.dart';

extension WidgetX on Widget {
  Widget paddedAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddedSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget get sliver => SliverToBoxAdapter(child: this);
}
