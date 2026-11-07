import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/entities/auth_session.dart';
import 'package:elyeter/features/auth/domain/entities/otp_challenge.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/widgets/app_asset_image.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dialog only ever reads the session off this, so a repository that
/// answers nothing is enough to build it.
class _IdleAuthRepository implements AuthRepository {
  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();

  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();

  @override
  Future<bool> hasSession() async => true;

  @override
  Future<Result<OtpChallenge>> sendCode(String phone) async =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<Result<AppUser>> updateProfile({
    String? username,
    String? image,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> updateFcmToken(String token, {String? lang}) async =>
      throw UnimplementedError();

  @override
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  }) async => throw UnimplementedError();
}

void main() {
  testWidgets('the dialog buttons are centred, not stretched to its edges', (
    tester,
  ) async {
    final auth = AuthCubit(_IdleAuthRepository());
    addTearDown(auth.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDeleteAccountDialog(
                  context,
                  auth: auth,
                  phone: '+99362123456',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final dialog = tester.getSize(find.byType(Dialog));
    final keep = tester.getRect(find.byType(FilledButton));

    // Sized to its label rather than to the dialog, and sitting on the
    // dialog's centre line.
    expect(keep.width, lessThan(dialog.width * 0.8));
    expect(keep.height, lessThanOrEqualTo(48));
    expect(
      keep.center.dx,
      moreOrLessEquals(
        tester.getRect(find.byType(Dialog)).center.dx,
        epsilon: 1,
      ),
    );

    final deleteIcon = tester.widget<AppAssetImage>(find.byType(AppAssetImage));
    expect(deleteIcon.path, AppAssets.iconTrash);
    expect(deleteIcon.width, 24);
  });
}
