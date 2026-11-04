import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../app/cubit/locale_cubit.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../profile/presentation/widgets/language_dialog.dart';
import '../../../profile/presentation/widgets/language_flag.dart';

/// First launch: choose an app language, then enter the shop.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _starting = false;

  Future<void> _chooseLanguage() async {
    final localeCubit = context.read<LocaleCubit>();
    final current =
        localeCubit.state?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final selected = await showLanguageDialog(context, current: current);
    if (selected != null && mounted) localeCubit.setLanguageCode(selected);
  }

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      await getIt<LocalStorage>().setBool(
        StorageKeys.onboardingSeen,
        value: true,
      );
      if (mounted) context.goNamed(AppRoutes.home.name);
    } catch (_) {
      if (!mounted) return;
      setState(() => _starting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorServer)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code =
        context.watch<LocaleCubit>().state?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final language = supportedLanguageOptions.firstWhere(
      (option) => option.code == code,
      orElse: () => supportedLanguageOptions.first,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scaleX: 2,
                alignment: Alignment.topCenter,
                child: ImageFiltered(
                  // flutter_svg skips the SVG's Gaussian filters; blur its
                  // original color shapes here to preserve the supplied fade.
                  imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                  child: SvgPicture.asset(
                    AppAssets.onboardingGradient,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            0,
                            AppSpacing.page,
                            64,
                          ),
                          child: Column(
                            children: [
                              const Spacer(),
                              SvgPicture.asset(
                                AppAssets.logoWhite,
                                width: 100,
                                height: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.onboardingWelcome,
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineLarge
                                    ?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.onboardingSubtitle,
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: AppColors.grey700,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Material(
                                color: const Color(0xFFF1F1F3),
                                borderRadius: BorderRadius.circular(28),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  key: const Key('onboarding-language'),
                                  onTap: _starting ? null : _chooseLanguage,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          LanguageFlag(
                                            languageCode: language.code,
                                            semanticsLabel: language.title,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              language.title,
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.ink,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20,
                                            color: AppColors.grey500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton(
                                    key: const Key('onboarding-start'),
                                    onPressed: _starting ? null : _start,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      // foregroundColor: AppColors.white,
                                      // disabledForegroundColor: AppColors.white,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      shape: const StadiumBorder(),
                                    ),
                                    child: _starting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: AppLoader(
                                              color: AppColors.white,
                                            ),
                                          )
                                        : Text(l10n.onboardingStart),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
