import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/cubit/locale_cubit.dart';
import '../../../../app/cubit/theme_cubit.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_reveal.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../order/domain/repositories/pre_order_repository.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/delete_account_card.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/guest_summary_card.dart';
import '../widgets/language_dialog.dart';
import '../widgets/profile_summary_cards.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/support_call_card.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// Account page: identity, app settings and support.
///
/// It draws the same list in two states. Signed in, the header shows the
/// account and the page ends with a way out of it; signed out, the header
/// invites the customer in and the account-only rows ask them to sign in
/// before they open. Everything that works without an account — the
/// language, the theme, the legal pages, support — stays reachable either
/// way, so the tab is never a dead end.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Keeps the editable profile in step with the session: it takes the
      // account's number on sign-in and is wiped on sign-out, so the next
      // person to use the phone does not meet someone else's name.
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.user != current.user,
      listener: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final user = state.user;
        if (state.isAuthenticated && user != null) {
          cubit.adoptAccount(phone: user.phone, name: user.username);
        } else if (state.status == AuthStatus.unauthenticated) {
          cubit.clearAccount();
        }
      },
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  ShopContacts? _contacts;
  int? _orderCount;
  bool _orderCountRequested = false;
  int? _loadedAccountId;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await getIt<ShopApi>().contacts();
      if (mounted) setState(() => _contacts = contacts);
    } on Object {
      /* An empty contact section is valid. */
    }
  }

  Future<void> _loadOrderCount() async {
    final accountId = getIt<AuthCubit>().state.user?.id;
    final result = await getIt<PreOrderRepository>().list(size: 1);
    if (mounted && getIt<AuthCubit>().state.user?.id == accountId) {
      setState(() => _orderCount = result.dataOrNull?.totalCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = context.watch<ThemeCubit>().state;
    final profile = context.watch<ProfileCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final auth = context.watch<AuthCubit>().state;
    final signedIn = auth.isAuthenticated;
    final guestTileWeight = signedIn ? null : FontWeight.w500;
    final guestSectionTitleStyle = signedIn
        ? null
        : context.textTheme.titleMedium?.copyWith(
            color: AppColors.iconSoft,
            fontWeight: FontWeight.w600,
          );
    if (_loadedAccountId != auth.user?.id) {
      _loadedAccountId = auth.user?.id;
      _orderCount = null;
      _orderCountRequested = false;
    }
    if (signedIn && !_orderCountRequested) {
      _orderCountRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrderCount());
    }

    return Scaffold(
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        // toolbarHeight: signedIn ? kToolbarHeight : 94,
        titleSpacing: AppSpacing.page,
        centerTitle: false,
        title: Text(
          l10n.profileTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: signedIn ? 20 : 24,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            signedIn ? 0 : 20,
            AppSpacing.page,
            // Clearance for the floating navigation bar.
            120,
          ),
          children: [
            if (signedIn) const SizedBox(height: AppSpacing.xxl),
            if (signedIn)
              ProfileSummaryCards(
                // Whatever the account actually knows, in the order it is
                // worth showing: the name typed here, then the one stored on
                // the account, then the number the account is — never a
                // stand-in person.
                name: _accountName(profile, auth),
                phone: auth.user?.phone ?? profile.phone,
                avatarUrl: MediaUrl.resolve(auth.user?.image),
                avatarPath: profile.avatarPath,
                editLabel: l10n.profileEditProfile,
                ordersTitle: l10n.profileAllOrders,
                ordersSubtitle: _orderCount == null
                    ? ''
                    : l10n.profileOrderCount(_orderCount!),
                onEditProfile: () =>
                    context.pushNamed(AppRoutes.editProfile.name),
                onOrders: () => context.pushNamed(AppRoutes.orders.name),
              )
            else
              GuestSummaryCard(
                title: l10n.profileGuestTitle,
                message: l10n.profileGuestMessage,
                actionLabel: l10n.profileGuestAction,
                onSignIn: () => context.pushNamed(AppRoutes.login.name),
              ),
            if (!signedIn) const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: l10n.profileSectionGeneral,
              titleStyle: guestSectionTitleStyle,
              children: [
                SettingsTile(
                  icon: AppAssets.iconBell,
                  label: l10n.profileNotifications,
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => context.pushNamed(AppRoutes.notifications.name),
                ),
                if (signedIn) ...[
                  SettingsTile(
                    icon: AppAssets.iconCubic,
                    label: l10n.profileActiveOrders,
                    onTap: () => _openAccountPage(
                      context,
                      signedIn,
                      AppRoutes.activeOrders.name,
                    ),
                  ),
                  SettingsTile(
                    icon: AppAssets.iconPinLocation,
                    label: l10n.profileSavedLocations,
                    onTap: () => _openAccountPage(
                      context,
                      signedIn,
                      AppRoutes.addresses.name,
                    ),
                  ),
                  SettingsTile(
                    icon: AppAssets.iconSearch,
                    label: l10n.productRequestMine,
                    onTap: () => _openAccountPage(
                      context,
                      signedIn,
                      AppRoutes.productRequests.name,
                    ),
                  ),
                ],
                SettingsTile(
                  icon: AppAssets.iconGlobe,
                  label: l10n.settingsLanguage,
                  trailing: TileValue(_languageLabel(context, locale)),
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => _pickLanguage(context),
                ),
                SettingsTile(
                  icon: AppAssets.iconMoon,
                  label: l10n.profileDarkMode,
                  verticalPadding: signedIn ? null : 6,
                  labelWeight: guestTileWeight,
                  trailing: TileSwitch(
                    value: _isDark(context, themeMode),
                    onChanged: (on) {
                      final cubit = context.read<ThemeCubit>();
                      void change() => cubit.setThemeMode(
                        on ? ThemeMode.dark : ThemeMode.light,
                      );
                      final reveal = ThemeReveal.maybeOf(context);
                      if (reveal == null) {
                        change();
                      } else {
                        unawaited(
                          reveal.run(
                            change,
                            direction: on
                                ? ThemeRevealDirection.leftToRight
                                : ThemeRevealDirection.rightToLeft,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            if (!signedIn) const SizedBox(height: AppSpacing.sm),
            SettingsSection(
              title: l10n.profileSectionOther,
              titleStyle: guestSectionTitleStyle,
              children: [
                SettingsTile(
                  icon: AppAssets.iconPhone,
                  label: l10n.profileAboutApp,
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => _openStaticPage(context, 'about'),
                ),
                SettingsTile(
                  icon: AppAssets.iconQuestion,
                  label: l10n.profileFaq,
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => _openStaticPage(context, 'faq'),
                ),
                SettingsTile(
                  icon: AppAssets.iconDocumentCheck,
                  label: l10n.profileTerms,
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => _openStaticPage(context, 'terms'),
                ),
                SettingsTile(
                  icon: AppAssets.iconLock,
                  label: l10n.profilePrivacy,
                  verticalPadding: signedIn ? null : 14,
                  labelWeight: guestTileWeight,
                  onTap: () => _openStaticPage(context, 'privacy'),
                ),
              ],
            ),
            if (_contacts?.instagramUrl != null ||
                _contacts?.tiktokUrl != null ||
                _contacts?.whatsappUrl != null ||
                _contacts?.telegramUrl != null ||
                _contacts?.imoUrl != null) ...[
              if (!signedIn) const SizedBox(height: AppSpacing.sm),
              SettingsSection(
                title: l10n.profileSectionContact,
                titleStyle: guestSectionTitleStyle,
                children: [
                  if (_contacts?.instagramUrl case final url?)
                    SettingsTile(
                      icon: AppAssets.iconInstagram,
                      label: l10n.profileInstagram,
                      trailing: const TileExternal(),
                      labelWeight: guestTileWeight,
                      onTap: () => _open(context, url),
                    ),
                  if (_contacts?.tiktokUrl case final url?)
                    SettingsTile(
                      icon: AppAssets.iconTiktok,
                      label: l10n.profileTiktok,
                      trailing: const TileExternal(),
                      labelWeight: guestTileWeight,
                      onTap: () => _open(context, url),
                    ),
                  if (_contacts?.whatsappUrl case final url?)
                    SettingsTile(
                      icon: AppAssets.iconWhatsapp,
                      label: l10n.profileWhatsapp,
                      trailing: const TileExternal(),
                      labelWeight: guestTileWeight,
                      onTap: () => _open(context, url),
                    ),
                  if (_contacts?.telegramUrl case final url?)
                    SettingsTile(
                      icon: AppAssets.iconTelegram,
                      label: 'Telegram',
                      trailing: const TileExternal(),
                      labelWeight: guestTileWeight,
                      onTap: () => _open(context, url),
                    ),
                  if (_contacts?.imoUrl case final url?)
                    SettingsTile(
                      icon: AppAssets.iconImo,
                      label: 'Imo',
                      trailing: const TileExternal(),
                      labelWeight: guestTileWeight,
                      onTap: () => _open(context, url),
                    ),
                ],
              ),
            ],
            for (final phone in {
              _contacts?.phonePrimary,
              _contacts?.phoneSecondary,
            }.whereType<String>().where((p) => p.trim().isNotEmpty)) ...[
              SizedBox(height: signedIn ? AppSpacing.xl : AppSpacing.sm),
              SupportCallCard(
                title: l10n.profileCallTitle,
                phone: phone,
                hours: l10n.profileCallHours,
                hoursHighlight: '',
                actionLabel: l10n.profileCallAction,
                onCall: () => _open(context, 'tel:$phone'),
              ),
            ],
            if (signedIn) ...[
              const SizedBox(height: AppSpacing.xl),
              DeleteAccountCard(
                label: l10n.profileDeleteAccount,
                onPressed: () => _deleteAccount(context, auth.user?.phone),
              ),
            ],
            if (signedIn) ...[
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  l10n.profileVersion(AppConstants.appVersion),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// What the profile card puts above "edit profile".
  ///
  /// The phone number is the account's identity and is always known, so it
  /// stands in for a name that has not been given — an empty header reads
  /// as a page that failed to load rather than as an invitation.
  String _accountName(ProfileState profile, AuthState auth) {
    if (profile.hasName) return profile.name;
    final username = auth.user?.username?.trim() ?? '';
    if (username.isNotEmpty) return username;
    return auth.user?.phone ?? profile.phone;
  }

  void _openStaticPage(BuildContext context, String slug) => context.pushNamed(
    AppRoutes.staticPage.name,
    pathParameters: {'slug': slug},
  );

  bool _isDark(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark,
  };

  String _languageLabel(BuildContext context, Locale? locale) {
    final l10n = context.l10n;
    return switch (_languageCode(context, locale)) {
      'tk' => l10n.settingsLanguageTurkmen,
      'ru' => l10n.settingsLanguageRussian,
      _ => l10n.settingsLanguageEnglish,
    };
  }

  // With the system setting, use the language currently resolved by the app.
  String _languageCode(BuildContext context, Locale? locale) =>
      locale?.languageCode ?? Localizations.localeOf(context).languageCode;

  Future<void> _pickLanguage(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final picked = await showLanguageDialog(
      context,
      current: _languageCode(context, cubit.state),
    );
    if (picked != null) cubit.setLanguageCode(picked);
  }

  /// Orders, addresses and notifications all describe one account, so a
  /// signed-out tap asks for the account first and then carries on to the
  /// page that was tapped.
  Future<void> _openAccountPage(
    BuildContext context,
    bool signedIn,
    String routeName,
  ) async {
    if (signedIn) {
      await context.pushNamed(routeName);
      return;
    }
    if (await promptSignIn(context) && context.mounted) {
      await context.pushNamed(routeName);
    }
  }

  /// `DELETE /auth/me`, behind the confirmation dialog that owns the request
  /// and reports its own failures. Nothing is done here on a refusal — the
  /// dialog has already said why, and the account is untouched.
  Future<void> _deleteAccount(BuildContext context, String? phone) async {
    final deleted = await showDeleteAccountDialog(
      context,
      auth: context.read<AuthCubit>(),
      phone: phone,
    );

    // The session is already gone, so the page has swapped itself back to
    // the guest header by now; this only confirms what happened.
    if (deleted && context.mounted) {
      AppSnackBar.show(
        context,
        context.l10n.profileDeleteDone,
        overNavBar: true,
      );
    }
  }

  /// Hands [url] to the platform: `tel:` opens the dialler with the support
  /// number in it, the rest open in their own app or the browser.
  ///
  /// A phone that cannot take the link — a tablet with no dialler, a missing
  /// WhatsApp — says so rather than swallowing the tap.
  Future<void> _open(BuildContext context, String url) async {
    final failed = context.l10n.commonOpenFailed(url);

    var launched = false;
    try {
      launched = await launchUrl(
        Uri.parse(url),
        // The dialler and WhatsApp are separate apps; only a plain web link
        // has any business inside an in-app browser.
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      launched = false;
    }

    if (!launched && context.mounted) {
      AppSnackBar.show(
        context,
        failed,
        icon: AppIcons.error,
        iconColor: AppColors.error,
        overNavBar: true,
      );
    }
  }
}
