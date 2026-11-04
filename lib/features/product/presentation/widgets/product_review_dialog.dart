import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../domain/entities/product_reviews.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/utils/photo_upload_compressor.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import 'product_review_button.dart';

/// Returns true after saving so either product screen can refresh its reviews.
Future<bool> showProductReviewDialog(
  BuildContext context, {
  required int productId,
  ProductReviewEntry? review,
}) async {
  final repository = getIt<ProductRepository>();
  if (!context.read<AuthCubit>().state.isAuthenticated) {
    if (!await promptSignIn(context) || !context.mounted) return false;
    // Reviews loaded while signed out do not include the customer's review.
    final result = await repository.reviews(productId, page: 1, size: 1);
    if (!context.mounted) return false;
    if (result.isError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reviewLoadError)));
      return false;
    }
    review = result.dataOrNull?.myReview;
  }
  if (!context.mounted) return false;
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => _ProductReviewPage(
        productId: productId,
        repository: repository,
        review: review,
      ),
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.reviewSaved)));
  }
  return saved ?? false;
}

class _ProductReviewPage extends StatefulWidget {
  const _ProductReviewPage({
    required this.productId,
    required this.repository,
    this.review,
  });

  final int productId;
  final ProductRepository repository;
  final ProductReviewEntry? review;

  @override
  State<_ProductReviewPage> createState() => _ProductReviewPageState();
}

class _ProductReviewPageState extends State<_ProductReviewPage> {
  late int _rating = widget.review?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.review?.comment);
  bool _saving = false;
  bool _failed = false;
  bool _uploadFailed = false;
  static const _maxPhotos = 5;

  /// Photos the review will carry: the ones it already has, then new ones
  /// as they finish uploading.
  late final List<_Photo> _photos = [
    for (final image in widget.review?.images ?? const <ProductReviewImage>[])
      _Photo(objectName: image.objectName, url: image.url),
  ];

  bool get _uploading => _photos.any((photo) => photo.uploading);

  Future<void> _addPhotos() async {
    final room = _maxPhotos - _photos.length;
    if (room <= 0 || _saving) return;
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
      limit: room,
    );
    if (picked.isEmpty || !mounted) return;
    for (final file in picked.take(room)) {
      final photo = _Photo(path: file.path, uploading: true);
      setState(() {
        _photos.add(photo);
        _uploadFailed = false;
      });
      // Uploads run while the customer keeps typing.
      unawaited(
        compressImageToLimit(
          file.path,
        ).then(widget.repository.uploadReviewImage).then((result) {
          if (!mounted) return;
          setState(() {
            if (result.dataOrNull case final image?) {
              photo
                ..objectName = image.objectName
                ..url = image.url
                ..uploading = false;
            } else {
              _photos.remove(photo);
              _uploadFailed = true;
            }
          });
        }),
      );
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _uploading || _rating == 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _failed = false;
    });
    final comment = _comment.text.trim();
    final result = await widget.repository.saveReview(
      widget.productId,
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
      // The whole list, so photos taken off a review are removed from it.
      images: [for (final photo in _photos) photo.objectName!],
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? AppColors.grey700 : const Color(0xFFEDEDED);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppPageAppBar(
          title: widget.review == null ? l10n.reviewWrite : l10n.reviewEdit,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xl,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  children: [
                    Text(
                      l10n.reviewHowRate,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            for (var star = 1; star <= 5; star++) ...[
                              if (star > 1)
                                Container(width: 1, height: 58, color: border),
                              Expanded(
                                child: InkWell(
                                  key: ValueKey('review-star-$star'),
                                  onTap: _saving
                                      ? null
                                      : () => setState(() => _rating = star),
                                  child: SizedBox(
                                    height: 58,
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 32,
                                      color: star <= _rating
                                          ? AppColors.primaryVibrant
                                          : const Color(0xFFE4E4E7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _comment,
                      enabled: !_saving,
                      maxLength: 2000,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }) => currentLength < 1800
                          ? null
                          : Text(
                              '$currentLength/$maxLength',
                              style: context.textTheme.labelSmall,
                            ),
                      minLines: 6,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.reviewComment,
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey500,
                        ),
                        filled: true,
                        fillColor: dark
                            ? AppColors.grey900
                            : const Color(0xFFF0F0F2),
                        contentPadding: const EdgeInsets.all(AppSpacing.lg),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                            color: AppColors.primaryVibrant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PhotoStrip(
                      photos: _photos,
                      maxPhotos: _maxPhotos,
                      enabled: !_saving,
                      addLabel: l10n.reviewAddPhotos,
                      hint: _uploadFailed
                          ? l10n.reviewPhotoUploadError
                          : l10n.reviewPhotoLimit,
                      hintIsError: _uploadFailed,
                      onAdd: _addPhotos,
                      onRemove: (photo) =>
                          setState(() => _photos.remove(photo)),
                    ),
                    if (_failed) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.reviewActionError,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.lg,
                ),
                child: ProductReviewButton(
                  label: widget.review == null
                      ? l10n.reviewSubmit
                      : l10n.commonSave,
                  loading: _saving,
                  onPressed: _rating == 0 || _uploading ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Photo {
  _Photo({this.objectName, this.url, this.path, this.uploading = false});

  String? objectName;
  String? url;
  final String? path;
  bool uploading;
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.photos,
    required this.maxPhotos,
    required this.enabled,
    required this.addLabel,
    required this.hint,
    required this.hintIsError,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_Photo> photos;
  final int maxPhotos;
  final bool enabled;
  final String addLabel;
  final String hint;
  final bool hintIsError;
  final VoidCallback onAdd;
  final void Function(_Photo) onRemove;

  static const _size = 84.0;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? AppColors.grey500 : const Color(0xFFCFCFD4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _size + 10,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              if (photos.length < maxPhotos)
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: AppSpacing.sm),
                  child: Semantics(
                    button: true,
                    label: addLabel,
                    child: GestureDetector(
                      key: const Key('review-add-photo'),
                      onTap: enabled ? onAdd : null,
                      child: CustomPaint(
                        painter: _DashedRRect(
                          color: line,
                          radius: AppRadius.lg,
                        ),
                        child: SizedBox(
                          width: _size,
                          height: _size,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 26,
                                color: AppColors.primaryVibrant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${photos.length}/$maxPhotos',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: AppColors.grey500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              for (final photo in photos)
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: AppSpacing.sm),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: SizedBox(
                          width: _size,
                          height: _size,
                          child: photo.path != null
                              ? Image.file(File(photo.path!), fit: BoxFit.cover)
                              : Image.network(photo.url!, fit: BoxFit.cover),
                        ),
                      ),
                      if (photo.uploading)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: AppLoader(color: AppColors.white),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: enabled ? () => onRemove(photo) : null,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: AppColors.ink,
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          hint,
          style: context.textTheme.labelSmall?.copyWith(
            color: hintIsError ? AppColors.error : AppColors.grey500,
          ),
        ),
      ],
    );
  }
}

class _DashedRRect extends CustomPainter {
  const _DashedRRect({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) =>
      old.color != color || old.radius != radius;
}
