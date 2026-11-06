import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../../core/constants/app_icons.dart';

/// Frequently asked questions, one expandable card each: the list stays
/// scannable and only the answer being read takes up room.
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  /// Only one answer open at a time, so the page never becomes a wall.
  int? _open = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(String, String)>[
      (l10n.faqQ1, l10n.faqA1),
      (l10n.faqQ2, l10n.faqA2),
      (l10n.faqQ3, l10n.faqA3),
      (l10n.faqQ4, l10n.faqA4),
      (l10n.faqQ5, l10n.faqA5),
    ];

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.faqTitle),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _FaqTile(
          question: items[index].$1,
          answer: items[index].$2,
          open: _open == index,
          onTap: () => setState(() => _open = _open == index ? null : index),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.open,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? AppColors.surfaceDark
          : context.adapt(AppColors.surfaceMuted, AppColors.categoryDark),
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: open ? AppColors.primary : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      turns: open ? 0.5 : 0,
                      child: HugeIcon(
                        icon: AppIcons.chevronDown,
                        color: open ? AppColors.primary : AppColors.iconSoft,
                      ),
                    ),
                  ],
                ),
                if (open) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.adapt(
                        AppColors.grey700,
                        AppColors.iconSoft,
                      ),
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
