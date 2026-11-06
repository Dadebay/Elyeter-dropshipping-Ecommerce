import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// One heading plus its paragraph.
class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Shared body for the written pages — terms, privacy, and anything else
/// that is a list of headed paragraphs.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({super.key, required this.sections, this.footer});

  final List<LegalSection> sections;

  /// Small grey line at the end, e.g. the last-updated date.
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      itemCount: sections.length + (footer == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, index) {
        if (index == sections.length) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          );
        }

        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A numbered marker keeps long documents scannable.
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: AppSpacing.md, top: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                section.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.adapt(AppColors.grey700, AppColors.iconSoft),
                  height: 1.55,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
