import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../cubit/login_cubit.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// The SMS login: a phone number, then the code that number receives.
///
/// Pops with `true` once the session exists, so whoever pushed the page —
/// the profile header, a gated row — can carry on.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  /// A Turkmen subscriber number is exactly 8 digits. `+993` is drawn as a
  /// fixed prefix rather than typed into the field, so it cannot be deleted,
  /// doubled or replaced with another country's code.
  static const _phoneDigits = 8;

  /// The SMS code is 4 digits.
  static const _codeDigits = 4;

  final _phone = TextEditingController();
  final _phoneFocus = FocusNode();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = _openTerms;

  String get _localPhoneDigits => _phone.text.replaceAll(' ', '');

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(_onPhoneFocusChanged);
  }

  void _onPhoneFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phone.dispose();
    _phoneFocus.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  void _openTerms() => context.pushNamed(AppRoutes.terms.name);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.backgroundDark : AppColors.white;

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.signedIn != current.signedIn ||
          previous.failure != current.failure ||
          previous.step != current.step,
      listener: (context, state) {
        final failure = state.failure;
        if (failure != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.localize(l10n))));
        }
        // A fresh code deserves an empty field, whether it is the first
        // one or a resend after a wrong entry.
        if (state.step == LoginStep.phone) _code.clear();

        if (state.signedIn) {
          AppSnackBar.show(context, l10n.loginSignedIn);
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: background,
          // The phone step stays put under the keyboard: the logo and the
          // legal notice must not ride up with it. The code step still
          // resizes, so its field stays in view.
          resizeToAvoidBottomInset: state.step != LoginStep.phone,
          appBar: AppBar(
            clipBehavior: Clip.none,
            toolbarHeight: kToolbarHeight,
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leadingWidth: AppBackButton.leadingWidth,
            leading: AppBackButton.appBarLeading(
              onPressed: state.step == LoginStep.code
                  ? () => context.read<LoginCubit>().editPhone()
                  : null,
            ),
          ),
          body: _stepSwitcher(context, state),
        );
      },
    );
  }

  /// Moving on to the code slides the phone step off to the left and the code
  /// in from the right; going back reverses it.
  Widget _stepSwitcher(BuildContext context, LoginState state) {
    final onCode = state.step == LoginStep.code;
    final forward = onCode;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) =>
            Stack(children: [...previous, ?current]),
        transitionBuilder: (child, animation) {
          final entering = child.key == ValueKey(onCode);
          // The entering page starts one width to the right (or left when
          // going back); the leaving page's reversed animation carries it off
          // the opposite side.
          final from = entering
              ? (forward ? 1.0 : -1.0)
              : (forward ? -1.0 : 1.0);
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(from, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(onCode),
          child: onCode
              ? _codeStep(context, state)
              : _phoneStep(context, state),
        ),
      ),
    );
  }

  Widget _phoneStep(BuildContext context, LoginState state) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.white : AppColors.black;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final canContinue =
        _localPhoneDigits.length == _phoneDigits && !state.submitting;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                SvgPicture.asset(AppAssets.iconLoginBag, width: 56, height: 56),
                const SizedBox(height: 16),
                Text(
                  l10n.loginPhoneTitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    l10n.loginPhoneMessage,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: TextField(
                    controller: _phone,
                    focusNode: _phoneFocus,
                    enabled: !state.submitting,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    inputFormatters: const [_PhoneNumberFormatter()],
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.loginPhoneHint,
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                      prefix: _PhonePrefix(
                        visible: _phoneFocus.hasFocus || _phone.text.isNotEmpty,
                        reduceMotion: reduceMotion,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(),
                      suffixIcon: _PhoneClearButton(
                        visible: _phoneFocus.hasFocus && !state.submitting,
                        reduceMotion: reduceMotion,
                        isDark: isDark,
                        onPressed: () {
                          _phone.clear();
                          _phoneFocus.unfocus();
                          setState(() {});
                        },
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.grey900
                          : const Color(0xFFF1F1F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    // Typing the last digit only enables "Dowam etmek"; the
                    // customer sends the code themselves.
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (_) {
                      if (canContinue) _sendCode(context);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: canContinue || state.submitting
                        ? AppColors.primaryGradient
                        : null,
                    // Disabled: pale peach on light; on dark a muted warm tone,
                    // since peach would glare against the dark page.
                    color: canContinue || state.submitting
                        ? null
                        : (isDark
                              ? const Color(0xFF3D2A20)
                              : const Color(0xFFFFC39E)),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isDark && (canContinue || state.submitting)
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        disabledForegroundColor: isDark
                            ? AppColors.white.withValues(alpha: 0.45)
                            : AppColors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: canContinue ? () => _sendCode(context) : null,
                      child: state.submitting
                          ? const _ButtonSpinner()
                          : Text(l10n.loginSendCode),
                    ),
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l10n.loginLegalNotice} '),
                        TextSpan(
                          text: l10n.loginReadTerms,
                          style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _termsTap,
                        ),
                      ],
                    ),
                    key: const Key('login-legal-notice'),
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      height: 1.35,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _codeStep(BuildContext context, LoginState state) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.white : AppColors.black;
    final code = _code.text;
    final codeColor = state.submitting && code.length == _codeDigits
        ? const Color(0xFF20C46A)
        : state.failure != null && code.length == _codeDigits
        ? const Color(0xFFFF4B55)
        : ink;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        68,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.iconOtpNotification,
              width: 56,
              height: 56,
            ),
            const SizedBox(height: 18),
            Text(
              l10n.loginCodeTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginCodeMessage(_displayPhone(state.phone)),
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 15,
                color: isDark ? AppColors.grey300 : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 42),
            SizedBox(
              width: 222,
              height: 52,
              child: Stack(
                children: [
                  ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var index = 0; index < _codeDigits; index++)
                          Container(
                            key: Key('otp-digit-$index'),
                            width: 48,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.grey900
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: index < code.length
                                ? Text(
                                    code[index],
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: codeColor,
                                        ),
                                  )
                                : code.length == index && !state.submitting
                                ? Container(width: 2, height: 22, color: ink)
                                : null,
                          ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: TextField(
                      controller: _code,
                      focusNode: _codeFocus,
                      autofocus: true,
                      readOnly: state.submitting,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      maxLength: _codeDigits,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      showCursor: false,
                      // The boxes draw the digits; no selection handle (the
                      // orange drop) should ever show over them.
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        hintText: l10n.loginCodeLabel,
                        hintStyle: const TextStyle(color: Colors.transparent),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        if (state.failure != null &&
                            _code.text.length == _codeDigits) {
                          _code.clear();
                          setState(() {});
                        }
                      },
                      onChanged: (value) {
                        setState(() {});
                        if (value.length == _codeDigits) _verify(context);
                      },
                      onSubmitted: (_) => _verify(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: state.submitting ? 20 : 12),
            if (state.submitting && code.length == _codeDigits)
              SizedBox(width: 18, height: 18, child: AppLoader(color: ink))
            else
              TextButton(
                onPressed: state.canResend ? () => _resend(context) : null,
                style: TextButton.styleFrom(
                  foregroundColor: ink,
                  disabledForegroundColor: AppColors.iconSoft,
                ),
                child: Text(
                  state.resendIn > 0
                      ? l10n.loginResendCountdown(
                          '${(state.resendIn ~/ 60).toString().padLeft(2, '0')}:${(state.resendIn % 60).toString().padLeft(2, '0')}',
                        )
                      : l10n.loginResend,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 13,
                    color: state.canResend ? ink : AppColors.iconSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _displayPhone(String phone) {
    if (phone.startsWith('+993') && phone.length == 12) {
      final local = phone.substring(4);
      return '${local.substring(0, 2)} ${local.substring(2)}';
    }
    return phone;
  }

  void _resend(BuildContext context) {
    _code.clear();
    setState(() {});
    _codeFocus.requestFocus();
    unawaited(context.read<LoginCubit>().resend());
  }

  void _sendCode(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    if (cubit.state.submitting ||
        cubit.state.step != LoginStep.phone ||
        _localPhoneDigits.length != _phoneDigits) {
      return;
    }
    unawaited(cubit.sendCode(_localPhoneDigits));
  }

  void _verify(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    if (cubit.state.submitting || _code.text.length != _codeDigits) return;
    FocusScope.of(context).unfocus();
    unawaited(cubit.verify(_code.text));
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: AppLoader(color: AppColors.white),
  );
}

class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix({
    required this.visible,
    required this.reduceMotion,
    required this.style,
  });

  final bool visible;
  final bool reduceMotion;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: visible ? 1 : 0),
    duration: Duration(milliseconds: reduceMotion ? 80 : 180),
    curve: Curves.easeOutCubic,
    builder: (context, progress, child) => ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Opacity(
          key: const Key('login-phone-prefix-opacity'),
          opacity: progress,
          child: Transform.translate(
            offset: Offset(reduceMotion ? 0 : -6 * (1 - progress), 0),
            child: child,
          ),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text('+993', style: style),
    ),
  );
}

class _PhoneClearButton extends StatelessWidget {
  const _PhoneClearButton({
    required this.visible,
    required this.reduceMotion,
    required this.isDark,
    required this.onPressed,
  });

  final bool visible;
  final bool reduceMotion;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: visible ? 1 : 0),
    duration: Duration(milliseconds: reduceMotion ? 80 : 180),
    curve: Curves.easeOutCubic,
    builder: (context, progress, child) => ClipRect(
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: progress,
        child: IgnorePointer(
          ignoring: !visible,
          child: Opacity(
            key: const Key('login-phone-clear-opacity'),
            opacity: progress,
            child: Transform.scale(
              scale: reduceMotion ? 1 : 0.94 + 0.06 * progress,
              child: child,
            ),
          ),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(right: 14),
      child: IconButton(
        key: const Key('login-phone-clear'),
        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          foregroundColor: isDark ? AppColors.white : AppColors.grey700,
          shape: const CircleBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(28, 28),
          maximumSize: const Size(28, 28),
        ),
        onPressed: onPressed,
        icon: SvgPicture.asset(
          isDark ? AppAssets.iconClearCircleDark : AppAssets.iconClearCircle,
          width: 28,
          height: 28,
        ),
      ),
    ),
  );
}

/// Displays local numbers as `65 855873` while keeping the value sent to the
/// API as eight digits. Also accepts a complete `+993` number when pasted.
class _PhoneNumberFormatter extends TextInputFormatter {
  const _PhoneNumberFormatter();

  static final _nonDigit = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(_nonDigit, '');
    final selectionEnd = newValue.selection.baseOffset
        .clamp(0, newValue.text.length)
        .toInt();
    var digitsBeforeCursor = newValue.text
        .substring(0, selectionEnd)
        .replaceAll(_nonDigit, '')
        .length;

    if (digits.length > 8 && digits.startsWith('993')) {
      digits = digits.substring(3);
      digitsBeforeCursor = (digitsBeforeCursor - 3).clamp(0, 8).toInt();
    }
    if (digits.length > 8) digits = digits.substring(0, 8);

    final text = digits.length > 2
        ? '${digits.substring(0, 2)} ${digits.substring(2)}'
        : digits;
    final cursorDigits = digitsBeforeCursor.clamp(0, digits.length).toInt();
    final cursor = cursorDigits > 2 ? cursorDigits + 1 : cursorDigits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}
