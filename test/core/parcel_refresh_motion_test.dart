import 'package:elyeter/core/constants/app_icons.dart';
import 'package:elyeter/core/widgets/parcel_refresh_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the package visibly moves while animations are enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: ParcelRefreshMotion(size: 30))),
      ),
    );

    final icon = find.byType(HugeIcon);
    final start = tester.getTopLeft(icon);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(icon).dy, isNot(start.dy));
  });

  testWidgets('the package stays still when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: Center(child: ParcelRefreshMotion(size: 30))),
        ),
      ),
    );

    final icon = find.byType(HugeIcon);
    final start = tester.getTopLeft(icon);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(icon), start);
  });
}
