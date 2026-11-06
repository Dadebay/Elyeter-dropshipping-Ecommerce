import 'dart:io';

import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:elyeter/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:elyeter/features/profile/presentation/widgets/profile_summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};
  @override
  dynamic read(String key) => values[key];
  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<void> clear() async => values.clear();
  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('profile_avatar_');
    HydratedBloc.storage = _MemoryStorage();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => '${directory.path}/documents',
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await directory.delete(recursive: true);
  });

  test(
    'saved avatar survives deletion of the picker cache and reload',
    () async {
      final source = File('${directory.path}/picked.jpg');
      await source.writeAsBytes([1, 2, 3, 4]);
      final profile = ProfileCubit();
      addTearDown(profile.close);
      await profile.save(name: 'Myradow Maksat', avatarPath: source.path);
      final persisted = profile.toJson(profile.state)!;
      await source.delete();

      final restored = profile.fromJson(persisted)!;
      expect(restored.avatarPath, startsWith('${directory.path}/documents/'));
      expect(await File(restored.avatarPath!).readAsBytes(), [1, 2, 3, 4]);
      await profile.save(name: 'Updated', avatarPath: restored.avatarPath);
      expect(profile.state.avatarPath, restored.avatarPath);
    },
  );

  test('saving a name clears an already missing avatar path', () async {
    final profile = ProfileCubit();
    addTearDown(profile.close);
    await profile.save(
      name: 'Myradow Maksat',
      avatarPath: '${directory.path}/deleted.jpg',
    );
    expect(profile.state.name, 'Myradow Maksat');
    expect(profile.state.avatarPath, isNull);
  });

  for (final corrupt in [false, true]) {
    testWidgets(
      '${corrupt ? 'corrupt' : 'missing'} avatar shows initials in both profile views',
      (tester) async {
        final photo = File('${directory.path}/avatar.jpg');
        if (corrupt) {
          await tester.runAsync(() => photo.writeAsString('invalid image'));
        }
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Column(
                children: [
                  ProfileSummaryCards(
                    name: 'Myradow Maksat',
                    editLabel: 'Edit profile',
                    ordersTitle: 'Orders',
                    ordersSubtitle: '',
                    avatarPath: photo.path,
                  ),
                  EditProfileAvatar(
                    name: 'Myradow Maksat',
                    imagePath: photo.path,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        // File reads and the image decoder finish outside the fake test clock.
        for (
          var attempt = 0;
          attempt < 20 && find.text('MM').evaluate().length < 2;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump();
        }
        expect(tester.takeException(), isNull);
        expect(find.text('MM'), findsNWidgets(2));
      },
    );
  }
}
