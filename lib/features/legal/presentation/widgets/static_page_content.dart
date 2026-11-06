import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared reading layout for the published pages. The server owns the text
/// and its semantic markup; the app owns spacing, typography and theme colors.
class StaticPageContent extends StatelessWidget {
  const StaticPageContent({
    super.key,
    required this.slug,
    required this.title,
    required this.body,
  });

  final String slug;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = theme.textTheme.bodyLarge!.color!;
    final surface = dark
        ? AppColors.surfaceDark
        : context.adapt(AppColors.surfaceMuted, AppColors.categoryDark);
    final accent = dark ? AppColors.primaryFade : AppColors.primaryDark;
    final icon = switch (slug) {
      'about' => AppAssets.iconPhone,
      'faq' => AppAssets.iconQuestion,
      'terms' => AppAssets.iconDocumentCheck,
      'privacy' => AppAssets.iconLock,
      _ => AppAssets.iconNews,
    };

    Style heading(double size) => Style(
      fontSize: FontSize(size),
      fontWeight: FontWeight.w700,
      lineHeight: const LineHeight(1.3),
      margin: Margins.only(top: 28, bottom: 12),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        key: PageStorageKey('static-page-$slug'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xxl,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: dark
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          icon,
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            accent,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          key: const Key('static-page-heading'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: ink,
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  key: const Key('static-page-content-card'),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: SelectionArea(
                    child: Html(
                      data: body,
                      style: {
                        // Editor-supplied foreground/background colors must
                        // not produce black text on a dark page.
                        '*': Style(
                          fontFamily: AppTypography.fontFamily,
                          color: ink,
                          backgroundColor: Colors.transparent,
                        ),
                        'html': Style(fontFamily: AppTypography.fontFamily),
                        'body': Style(
                          fontSize: FontSize(16),
                          lineHeight: const LineHeight(1.65),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        'p': Style(
                          fontFamily: AppTypography.fontFamily,
                          margin: Margins.only(bottom: 16),
                        ),
                        'h1': heading(26),
                        'h2': heading(22),
                        'h3': heading(19),
                        'h4': heading(17),
                        'h5': heading(16),
                        'h6': heading(16),
                        'ul, ol': Style(
                          margin: Margins.only(bottom: 20),
                          padding: HtmlPaddings.only(left: 22),
                        ),
                        'li': Style(margin: Margins.only(bottom: 8)),
                        'a, a *': Style(
                          color: accent,
                          textDecoration: TextDecoration.underline,
                          textDecorationColor: accent,
                        ),
                        'blockquote': Style(
                          margin: Margins.symmetric(vertical: 20),
                          padding: HtmlPaddings.only(left: 16),
                          border: Border(
                            left: BorderSide(color: accent, width: 3),
                          ),
                        ),
                        'hr': Style(
                          margin: Margins.symmetric(vertical: 24),
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        'body > :first-child': Style(
                          margin: Margins.only(bottom: 16),
                        ),
                        'body > :last-child': Style(
                          margin: Margins.only(top: 0),
                        ),
                      },
                      onLinkTap: (url, _, _) {
                        final uri = Uri.tryParse(url ?? '');
                        if (uri != null &&
                            (uri.scheme == 'http' || uri.scheme == 'https')) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
