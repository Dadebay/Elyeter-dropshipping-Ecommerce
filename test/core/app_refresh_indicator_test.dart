import 'dart:async';

import 'package:elyeter/core/widgets/app_refresh_indicator.dart';
import 'package:elyeter/core/widgets/parcel_refresh_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scrolling toward later products does not start a refresh', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppRefreshIndicator(
            onRefresh: () async {
              calls++;
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 40,
              itemBuilder: (_, index) =>
                  SizedBox(height: 120, child: Text('Product $index')),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    expect(find.byType(ParcelRefreshMotion), findsNothing);
    await gesture.moveBy(const Offset(0, -300));
    await tester.pump();
    expect(calls, 0);
    expect(find.byType(ParcelRefreshMotion), findsNothing);
    await gesture.up();
  });

  testWidgets('collapsing category headers never shows the refresh loader', (
    tester,
  ) async {
    final nested = GlobalKey<NestedScrollViewState>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NestedScrollView(
            key: nested,
            headerSliverBuilder: (_, _) => const [
              SliverToBoxAdapter(child: SizedBox(height: 220)),
            ],
            body: AppRefreshIndicator(
              onRefresh: () async {
                calls++;
              },
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: 40,
                itemBuilder: (_, index) =>
                    SizedBox(height: 120, child: Text('Product $index')),
              ),
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(find.byType(ParcelRefreshMotion), findsNothing);
    }
    expect(nested.currentState!.outerController.offset, greaterThan(0));
    expect(nested.currentState!.innerController.offset, 0);
    expect(calls, 0);
    await gesture.up();
    await tester.pumpAndSettle();

    // Revealing the header again is ordinary scrolling, not a refresh.
    await tester.drag(find.byType(ListView), const Offset(0, 100));
    await tester.pump();
    expect(find.byType(ParcelRefreshMotion), findsNothing);
    expect(calls, 0);
  });

  testWidgets('pull to refresh shows the shared loader', (tester) async {
    final refresh = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppRefreshIndicator(
            onRefresh: () {
              calls++;
              return refresh.future;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 120, child: Text('Item'))],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);
    expect(find.byType(ParcelRefreshMotion), findsOneWidget);

    refresh.complete();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ParcelRefreshMotion), findsNothing);
  });

  testWidgets('refresh loader leaves the screen when scrolling into products', (
    tester,
  ) async {
    final refresh = Completer<void>();
    addTearDown(() {
      if (!refresh.isCompleted) refresh.complete();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppRefreshIndicator(
            onRefresh: () => refresh.future,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 40,
              itemBuilder: (_, index) =>
                  SizedBox(height: 120, child: Text('Product $index')),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ParcelRefreshMotion), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      greaterThan(0),
    );
    expect(find.byType(ParcelRefreshMotion), findsNothing);
  });
}
