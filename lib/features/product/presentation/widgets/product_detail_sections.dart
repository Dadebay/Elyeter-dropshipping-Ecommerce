import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/product_attribute.dart';
import 'product_outline_button.dart';
import 'product_price_details_sheet.dart';
import 'product_section_card.dart';

/// Green score pill, then how many have ordered it.
class ProductRatingRow extends StatelessWidget {
  const ProductRatingRow({super.key, this.rating, this.orderCount = 0});

  final double? rating;
  final int orderCount;

  @override
  Widget build(BuildContext context) {
    final score = rating;
    if (score == null && orderCount == 0) return const SizedBox.shrink();

    return Row(
      children: [
        if (score != null) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (orderCount > 0)
          Flexible(
            child: Text(
              context.l10n.productOrderCount(orderCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.inkColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// "Color: Pink" under a row of options.
class ProductOptionLabel extends StatelessWidget {
  const ProductOptionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.bodyMedium?.copyWith(
      color: context.adapt(AppColors.grey700, AppColors.iconSoft),
    ),
  );
}

/// Burgundy price, with the previous amount and orange discount beside it.
class ProductPriceCard extends StatelessWidget {
  const ProductPriceCard({
    super.key,
    required this.name,
    required this.price,
    this.oldPrice,
  });

  static const _priceColor = Color(0xFFAD1F2B);

  final String name;
  final num price;
  final num? oldPrice;

  @override
  Widget build(BuildContext context) {
    final was = oldPrice;
    final discount = was != null && was > price
        ? ((was - price) / was * 100).round()
        : null;

    return GestureDetector(
      onTap: () => showProductPriceDetailsSheet(
        context,
        name: name,
        price: price,
        oldPrice: oldPrice,
      ),

      child: ProductSectionCard(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.sm, 8),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.amount(
                        price,
                        locale: context.l10n.localeName,
                      ),
                      maxLines: 1,
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: _priceColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      AppConstants.currencySymbol,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _priceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (discount != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        CurrencyFormatter.amount(
                          was!,
                          locale: context.l10n.localeName,
                        ),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '-$discount%',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryVibrant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Tooltip(
              message: context.l10n.productPriceDetails,
              child: SizedBox.square(
                dimension: 40,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: context.adapt(AppColors.grey700, AppColors.iconSoft),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The article number, with a copy button beside it.
class ProductArticleCard extends StatelessWidget {
  const ProductArticleCard({super.key, required this.article});

  final String article;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.productArticle,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.inkColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  article,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.adapt(AppColors.grey700, AppColors.iconSoft),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _CopyButton(article: article),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.article});

  final String article;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Figma: two drop shadows, #0E121B at 3.14% and 5.88%.
        // Dark mode: a faint white glow instead, so the edge still reads.
        boxShadow: context.isDark
            ? const [
                BoxShadow(color: Color(0x14FFFFFF), blurRadius: 4),
                BoxShadow(
                  color: Color(0x1FFFFFFF),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(color: Color(0x080E121B), blurRadius: 4),
                BoxShadow(
                  color: Color(0x0F0E121B),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _copy(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.productCopy,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.inkColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SvgPicture.asset(
                  AppAssets.iconCopy,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    context.inkColor,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final copied = context.l10n.productCopied;
    await Clipboard.setData(ClipboardData(text: article));
    if (context.mounted) AppSnackBar.show(context, copied);
  }
}

/// The description, collapsed to a few lines with the link running on from
/// the last one, as the design draws it.
///
/// The API sends HTML, so it is flattened to text first. Nothing is shown
/// when there is nothing to say.
class ProductDescriptionCard extends StatefulWidget {
  const ProductDescriptionCard({super.key, required this.description});

  /// The API's description, HTML.
  final String description;

  /// Paragraph and line breaks kept, tags and entities gone.
  static String plainText(String source) {
    final spaced = source
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</(p|div|li|h[1-6]|tr)>', caseSensitive: false),
          '\n',
        );
    final text = html.parse(spaced).documentElement?.text ?? '';
    return text
        .replaceAll(' ', ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  @override
  State<ProductDescriptionCard> createState() => _ProductDescriptionCardState();
}

class _ProductDescriptionCardState extends State<ProductDescriptionCard> {
  /// Figma: six lines, then "Read More...".
  static const _collapsedLines = 6;

  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = () => setState(() => _expanded = !_expanded);
  bool _expanded = false;

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = ProductDescriptionCard.plainText(widget.description);
    if (text.isEmpty) return const SizedBox.shrink();

    // Figma: Inter Display Regular 14 / 20, letter spacing 0, #5C5C5C; the
    // "Read More" span is the same, in blue.
    final body = context.textTheme.bodyMedium!.copyWith(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: context.adapt(const Color(0xFF5C5C5C), AppColors.iconSoft),
    );
    final link = body.copyWith(color: AppColors.info);

    return ProductSectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productDescription,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) => Text.rich(
                _span(context, text, constraints.maxWidth, body, link),
                style: body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The paragraph with the link on the end of it. Flutter drops any span
  /// past `maxLines`, so the text is measured and cut here, leaving exactly
  /// enough room for the link on the last line.
  TextSpan _span(
    BuildContext context,
    String text,
    double maxWidth,
    TextStyle body,
    TextStyle link,
  ) {
    final direction = Directionality.of(context);
    final linkSpan = TextSpan(
      text: _expanded
          ? '  ${context.l10n.productReadLess}'
          : ' ${context.l10n.productReadMore}...',
      style: link,
      recognizer: _tap,
    );

    if (_expanded) {
      return TextSpan(text: text, style: body, children: [linkSpan]);
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: body),
      maxLines: _collapsedLines,
      textDirection: direction,
    )..layout(maxWidth: maxWidth);
    final exceeds = painter.didExceedMaxLines;
    if (!exceeds) {
      painter.dispose();
      return TextSpan(text: text, style: body);
    }

    final linkPainter = TextPainter(text: linkSpan, textDirection: direction)
      ..layout();
    final cut = painter.getPositionForOffset(
      Offset(
        maxWidth - linkPainter.width,
        painter.size.height - painter.preferredLineHeight / 2,
      ),
    );
    final end = painter.getOffsetBefore(cut.offset) ?? cut.offset;
    painter.dispose();
    linkPainter.dispose();

    return TextSpan(
      text: '${text.substring(0, end).trimRight()}…',
      style: body,
      children: [linkSpan],
    );
  }
}

/// Label/value rows joined by a dotted leader: a preview of the rows, with
/// the rest one tap away. The block grows in place rather than opening a
/// dialog.
class ProductCharacteristicsCard extends StatefulWidget {
  const ProductCharacteristicsCard({super.key, required this.attributes});

  /// Rows shown before the button takes over.
  static const _preview = 8;

  final List<ProductAttribute> attributes;

  @override
  State<ProductCharacteristicsCard> createState() =>
      _ProductCharacteristicsCardState();
}

class _ProductCharacteristicsCardState
    extends State<ProductCharacteristicsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.attributes.isEmpty) return const SizedBox.shrink();

    final rows = _expanded
        ? widget.attributes
        : widget.attributes.take(ProductCharacteristicsCard._preview);
    final hasMore =
        widget.attributes.length > ProductCharacteristicsCard._preview;

    return ProductSectionCard(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.productCharacteristics,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final row in rows)
              ProductCharacteristicRow(label: row.name, value: row.value),
            if (hasMore) ...[
              const SizedBox(height: 10),
              // Figma: the button is 345 wide in a 361 card, so it reaches
              // 8px into the card's padding on each side.
              LayoutBuilder(
                builder: (context, constraints) => SizedBox(
                  height: 40,
                  child: OverflowBox(
                    minWidth: constraints.maxWidth + 16,
                    maxWidth: constraints.maxWidth + 16,
                    child: ProductOutlineButton(
                      label: _expanded
                          ? context.l10n.commonClose
                          : context.l10n.productAllCharacteristics,
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One spec line: label, dotted leader, value — all on a single line. The two
/// texts are capped at a share of the row rather than made flexible, which
/// would wrap a long value and leave the leader dangling.
class ProductCharacteristicRow extends StatelessWidget {
  const ProductCharacteristicRow({
    super.key,
    required this.label,
    required this.value,
  });

  static const _labelShare = 0.42;
  static const _valueShare = 0.50;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * _labelShare,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                child: ProductDottedLine(),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * _valueShare,
              ),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.inkColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stays over the page: the one action the page exists for. Adding is a
/// gradient pill; once the product is in the cart solid brand orange grows in
/// from both sides and the label turns to "Added" with a tick. The main pill stays tappable: pressing it
/// again takes the product out.
class ProductStickyAddToCart extends StatelessWidget {
  const ProductStickyAddToCart({
    super.key,
    required this.added,
    required this.onTap,
    this.enabled = true,
  });

  static const _height = 56.0;
  static const _iconSlot = 24.0;

  final bool added;
  final VoidCallback onTap;

  /// False greys the button out, e.g. when the chosen variant is sold out.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final showAdded = added && enabled;
    final radius = BorderRadius.circular(AppRadius.pill);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: showAdded ? 1 : 0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, _) {
        final foreground = !enabled
            ? AppColors.grey500
            : Color.lerp(AppColors.white, AppColors.white, progress)!;

        return Row(
          children: [
            Expanded(
              child: Container(
                height: _height,
                decoration: BoxDecoration(
                  gradient: !enabled ? null : AppColors.primaryGradient,
                  color: !enabled
                      ? context.adapt(AppColors.grey100, AppColors.categoryDark)
                      : null,
                  borderRadius: radius,
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The deeper orange meets in the middle.
                      if (progress > 0) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress / 2,
                            heightFactor: 1,
                            child: const ColoredBox(color: AppColors.primary),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: progress / 2,
                            heightFactor: 1,
                            child: const ColoredBox(color: AppColors.primary),
                          ),
                        ),
                      ],
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: enabled ? onTap : null,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (progress >= 0.5 && enabled) ...[
                                  SizedBox(
                                    width: _iconSlot,
                                    height: _iconSlot,
                                    child: HugeIcon(
                                      icon: AppIcons.check,
                                      size: 20,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  added
                                      ? context.l10n.commonAdded
                                      : context.l10n.commonAddToCart,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
