import 'dart:async';

import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/services/push_service.dart';
import 'package:elyeter/core/theme/app_colors.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/core/widgets/app_back_button.dart';
import 'package:elyeter/core/widgets/app_loader.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/entities/auth_session.dart';
import 'package:elyeter/features/auth/domain/entities/otp_challenge.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/auth/presentation/cubit/login_cubit.dart';
import 'package:elyeter/features/auth/presentation/view/login_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _PushService extends Mock implements PushService {}

class _OtpRepository implements AuthRepository {
  String? verifiedCode;
  final sentPhones = <String>[];
  Completer<Result<OtpChallenge>>? pendingSend;
  Completer<Result<AuthSession>>? pendingVerify;
  int resendAfter = 0;

  @override
  Future<Result<OtpChallenge>> sendCode(String phone) async {
    sentPhones.add(phone);
    return pendingSend?.future ??
        Success(OtpChallenge(expiresIn: 180, resendAfter: resendAfter));
  }

  @override
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  }) async {
    verifiedCode = code;
    return pendingVerify?.future ?? const Error(NetworkFailure());
  }

  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<bool> hasSession() async => false;
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
}

void main() {
  tearDown(() async => getIt.reset());

  test('only a successful OTP verification registers the token once', () async {
    final repository = _OtpRepository();
    final auth = AuthCubit(repository);
    final login = LoginCubit(repository, auth);
    final push = _PushService();
    when(() => push.registerTokenAfterOtp()).thenAnswer((_) async {});
    getIt.registerSingleton<PushService>(push);
    addTearDown(() async {
      await login.close();
      await auth.close();
    });

    await login.sendCode('62123456');
    repository.pendingVerify = Completer<Result<AuthSession>>()
      ..complete(const Error(NetworkFailure()));
    await login.verify('1234');
    verifyNever(() => push.registerTokenAfterOtp());

    repository.pendingVerify = Completer<Result<AuthSession>>()
      ..complete(
        const Success(
          AuthSession(
            accessToken: 'access-token',
            user: AppUser(id: 1, phone: '+99362123456'),
          ),
        ),
      );
    await login.verify('1234');
    await login.verify('1234');

    expect(login.state.signedIn, isTrue);
    verify(() => push.registerTokenAfterOtp()).called(1);
  });

  Future<LoginCubit> pumpLogin(
    WidgetTester tester,
    _OtpRepository repository, {
    Locale locale = const Locale('en'),
  }) async {
    final auth = AuthCubit(repository);
    addTearDown(auth.close);
    final login = LoginCubit(repository, auth);
    getIt.registerSingleton<LoginCubit>(login);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...FallbackLocalizations.delegates,
        ],
        home: const LoginPage(),
      ),
    );
    await tester.pumpAndSettle();
    return login;
  }

  testWidgets('phone entry shows localized design on a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLogin(tester, _OtpRepository(), locale: const Locale('tk'));

    expect(find.text('Hasaba girmek'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      'Telefon belgiňiz',
    );
    expect(find.text('Dowam etmek'), findsOneWidget);
    final legal = tester.widget<Text>(
      find.byKey(const Key('login-legal-notice')),
    );
    expect(
      legal.textSpan!.toPlainText(),
      contains('edýärsiňiz. Şertleri okaň'),
    );
    expect(tester.getSize(find.byType(AppBackButton)), const Size(50, 36));
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone prefix and clear button animate with focus', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLogin(tester, _OtpRepository());
    final field = find.byType(TextField);
    final prefixOpacity = find.byKey(const Key('login-phone-prefix-opacity'));
    final clearOpacity = find.byKey(const Key('login-phone-clear-opacity'));
    expect(tester.widget<Opacity>(prefixOpacity).opacity, 0);
    expect(tester.widget<Opacity>(clearOpacity).opacity, 0);

    await tester.tap(field);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(tester.widget<Opacity>(prefixOpacity).opacity, greaterThan(0));
    expect(tester.widget<Opacity>(prefixOpacity).opacity, lessThan(1));
    expect(tester.widget<Opacity>(clearOpacity).opacity, greaterThan(0));
    expect(tester.widget<Opacity>(clearOpacity).opacity, lessThan(1));
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(prefixOpacity).opacity, 1);
    expect(tester.widget<Opacity>(clearOpacity).opacity, 1);
    expect(find.byKey(const Key('login-phone-clear')), findsOneWidget);

    await tester.enterText(field, '65 8558');
    await tester.pump();
    await tester.tap(find.byKey(const Key('login-phone-clear')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isFalse);
    expect(tester.widget<Opacity>(prefixOpacity).opacity, 0);
    expect(tester.widget<Opacity>(clearOpacity).opacity, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'complete phone sends once when confirmed and failed sends can be retried',
    (tester) async {
      final repository = _OtpRepository()
        ..pendingSend = Completer<Result<OtpChallenge>>();
      final login = await pumpLogin(tester, repository);

      await tester.enterText(find.byType(TextField), '6212345');
      await tester.pump();
      expect(repository.sentPhones, isEmpty);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '62 12345',
      );

      await tester.enterText(find.byType(TextField), '62123456');
      await tester.pump();
      expect(repository.sentPhones, isEmpty);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(repository.sentPhones, ['+99362123456']);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      repository.pendingSend!.complete(const Error(NetworkFailure()));
      await tester.pumpAndSettle();
      expect(repository.sentPhones, hasLength(1));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      repository.pendingSend = null;
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.sentPhones, ['+99362123456', '+99362123456']);
      expect(login.state.step, LoginStep.code);
    },
  );

  testWidgets('OTP field truncates pasted digits to four before verification', (
    tester,
  ) async {
    final repository = _OtpRepository();
    await pumpLogin(tester, repository);

    await tester.enterText(find.byType(TextField), '62123456');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.sentPhones, ['+99362123456']);

    final codeField = find.byType(TextField);
    expect(tester.widget<TextField>(codeField).maxLength, 4);
    expect(
      tester.widget<TextField>(codeField).maxLengthEnforcement,
      MaxLengthEnforcement.enforced,
    );

    await tester.enterText(codeField, '123456');
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(codeField).controller!.text, '1234');
    expect(repository.verifiedCode, '1234');
  });

  testWidgets('OTP screen follows entry, loading and error visual states', (
    tester,
  ) async {
    final repository = _OtpRepository()
      ..resendAfter = 33
      ..pendingVerify = Completer<Result<AuthSession>>();
    final login = await pumpLogin(tester, repository);

    await tester.enterText(find.byType(TextField), '62123456');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(login.state.step, LoginStep.code);
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight,
      kToolbarHeight,
    );
    expect(find.text('Verification'), findsOneWidget);
    expect(find.text('Enter the code sent to 62 123456'), findsOneWidget);
    expect(find.byKey(const Key('otp-digit-0')), findsOneWidget);
    expect(find.byKey(const Key('otp-digit-3')), findsOneWidget);
    expect(find.byKey(const Key('otp-digit-4')), findsNothing);
    final digitsCenter =
        (tester.getCenter(find.byKey(const Key('otp-digit-0'))).dx +
            tester.getCenter(find.byKey(const Key('otp-digit-3'))).dx) /
        2;
    expect(
      digitsCenter,
      closeTo(tester.getCenter(find.byType(Scaffold)).dx, 1),
    );
    final codeInput = tester.widget<TextField>(find.byType(TextField));
    expect(codeInput.decoration?.filled, isFalse);
    expect(codeInput.decoration?.focusedBorder, InputBorder.none);
    final firstBox = tester.widget<Container>(
      find.byKey(const Key('otp-digit-0')),
    );
    expect((firstBox.decoration as BoxDecoration).border, isNull);
    expect(
      tester.widget<Text>(find.text('Resend code 00:33')).style?.color,
      AppColors.iconSoft,
    );

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    expect(repository.verifiedCode, '1234');
    expect(
      tester.widget<Text>(find.text('1')).style?.color,
      const Color(0xFF20C46A),
    );
    expect(find.byType(AppLoader), findsOneWidget);

    repository.pendingVerify!.complete(
      const Error(ApiFailure(code: ApiCodes.otpInvalid, statusCode: 400)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<Text>(find.text('1')).style?.color,
      const Color(0xFFFF4B55),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

    await tester.pump(const Duration(seconds: 33));
    await tester.pump();
    expect(find.text('Resend code'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Resend code'));
    await tester.pump();
    expect(repository.sentPhones, ['+99362123456', '+99362123456']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

    await tester.tap(find.byType(AppBackButton).last);
    await tester.pumpAndSettle();
    expect(login.state.step, LoginStep.phone);
  });
}
