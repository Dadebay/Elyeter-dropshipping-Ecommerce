import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../product/presentation/widgets/product_review_button.dart';
import '../../domain/entities/product_request.dart';
import '../../domain/repositories/product_request_repository.dart';

/// "Didn't find a product? Send us a link" — asks a signed-out customer to
/// sign in first, since requests belong to an account.
///
/// Pass [showMyRequests] false when the sheet is opened from the requests
/// list itself, so it does not offer a way back to where it already is.
Future<void> openProductRequestSheet(
  BuildContext context, {
  bool showMyRequests = true,
}) async {
  if (!getIt<AuthCubit>().state.isAuthenticated) {
    final signedIn = await promptSignIn(context);
    if (!signedIn || !context.mounted) return;
  }
  final router = GoRouter.of(context);
  final next = await showModalBottomSheet<_After>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    barrierColor: AppColors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => _ProductRequestSheet(showMyRequests: showMyRequests),
  );
  switch (next) {
    case _OpenProduct(:final productId):
      unawaited(
        router.pushNamed(
          AppRoutes.productDetail.name,
          pathParameters: {'id': productId.toString()},
        ),
      );
    case _OpenRequests():
      unawaited(router.pushNamed(AppRoutes.productRequests.name));
    case null:
      break;
  }
}

/// Where to go once the sheet closes — navigated by the caller, so the
/// route is pushed from a context that outlives the sheet.
sealed class _After {
  const _After();
}

class _OpenProduct extends _After {
  const _OpenProduct(this.productId);
  final int productId;
}

class _OpenRequests extends _After {
  const _OpenRequests();
}

class _ProductRequestSheet extends StatefulWidget {
  const _ProductRequestSheet({required this.showMyRequests});

  final bool showMyRequests;

  @override
  State<_ProductRequestSheet> createState() => _ProductRequestSheetState();
}

class _ProductRequestSheetState extends State<_ProductRequestSheet> {
  /// The backend loads a product in 10–60 s; after a minute the customer is
  /// told a push will follow instead of being kept waiting.
  static const _pollInterval = Duration(seconds: 5);
  static const _pollFor = Duration(minutes: 1);

  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  /// Set once the server has accepted the link.
  ProductRequest? _request;

  /// Still polling a `PROCESSING` request.
  bool _polling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty || !mounted) return;
    setState(() {
      _controller.text = text;
      _error = null;
    });
  }

  Future<void> _send() async {
    // Sent as typed — a share text with words around the link included;
    // the server finds the link itself.
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await getIt<ProductRequestRepository>().create(text);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _sending = false;
          _request = data;
        });
        _settle(data);
      case Error(:final failure):
        setState(() {
          _sending = false;
          _error = failure.localize(context.l10n);
        });
    }
  }

  /// Opens an available product straight away, or waits on one that is
  /// still loading.
  void _settle(ProductRequest request) {
    if (request.status == ProductRequestStatus.available &&
        request.product != null) {
      Navigator.of(context).pop(_OpenProduct(request.product!.id));
      return;
    }
    if (request.status == ProductRequestStatus.processing) {
      unawaited(_poll(request.id));
    }
  }

  Future<void> _poll(int id) async {
    setState(() => _polling = true);
    final deadline = DateTime.now().add(_pollFor);
    while (mounted && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(_pollInterval);
      if (!mounted) return;
      final latest = (await getIt<ProductRequestRepository>().byId(
        id,
      )).dataOrNull;
      if (!mounted) return;
      if (latest == null) continue;
      setState(() => _request = latest);
      if (latest.status != ProductRequestStatus.processing) {
        setState(() => _polling = false);
        _settle(latest);
        return;
      }
    }
    if (mounted) setState(() => _polling = false);
  }

  void _reset() => setState(() {
    _request = null;
    _error = null;
    _controller.clear();
  });

  @override
  Widget build(BuildContext context) {
    final request = _request;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: request == null
                    ? _input(context)
                    : _status(context, request),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.productRequestTitle,
          style: theme.titleLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.productRequestMessage,
          style: theme.bodyMedium?.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _controller,
          enabled: !_sending,
          minLines: 1,
          maxLines: 4,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          decoration: InputDecoration(
            hintText: l10n.productRequestHint,
            errorText: _error,
            errorMaxLines: 3,
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              tooltip: l10n.productRequestPaste,
              onPressed: _sending ? null : _paste,
              icon: HugeIcon(
                icon: AppIcons.copy,
                size: 20,
                color: AppColors.grey700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => ProductReviewButton(
            label: l10n.productRequestSend,
            loading: _sending,
            onPressed: _controller.text.trim().isEmpty ? null : _send,
          ),
        ),
        if (widget.showMyRequests)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _OpenRequests()),
            child: Text(l10n.productRequestMine),
          ),
      ],
    );
  }

  Widget _status(BuildContext context, ProductRequest request) {
    final l10n = context.l10n;
    final theme = context.textTheme;
    final processing = request.status == ProductRequestStatus.processing;

    final (
      AppIconData icon,
      Color color,
      String title,
      String message,
    ) = switch (request.status) {
      // Still loading after a minute reads the same as "in review": the
      // customer is told a push will follow.
      ProductRequestStatus.processing when !_polling => (
        AppIcons.notification,
        AppColors.primary,
        l10n.productRequestLaterTitle,
        l10n.productRequestLaterMessage,
      ),
      ProductRequestStatus.processing => (
        AppIcons.search,
        AppColors.primary,
        l10n.productRequestLoadingTitle,
        l10n.productRequestLoadingMessage,
      ),
      ProductRequestStatus.inReview => (
        AppIcons.notification,
        AppColors.primary,
        l10n.productRequestReviewTitle,
        l10n.productRequestReviewMessage,
      ),
      ProductRequestStatus.rejected => (
        AppIcons.close,
        AppColors.error,
        l10n.productRequestRejectedTitle,
        l10n.productRequestRejectedMessage,
      ),
      ProductRequestStatus.failed => (
        AppIcons.information,
        AppColors.error,
        l10n.productRequestFailedTitle,
        l10n.productRequestFailedMessage,
      ),
      // Only reached when the product is missing from the response.
      ProductRequestStatus.available => (
        AppIcons.checkCircle,
        AppColors.success,
        l10n.productRequestAvailableTitle,
        l10n.productRequestAvailableMessage,
      ),
    };

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        SizedBox.square(
          dimension: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: processing && _polling
                  ? const AppLoader(size: 32)
                  : HugeIcon(icon: icon, size: 30, color: color),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.titleLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.bodyMedium?.copyWith(color: AppColors.grey700),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (request.status == ProductRequestStatus.rejected ||
            request.status == ProductRequestStatus.failed)
          ProductReviewButton(
            label: l10n.productRequestSendAnother,
            onPressed: _reset,
          )
        else
          ProductReviewButton(
            label: l10n.commonClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
        if (widget.showMyRequests)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _OpenRequests()),
            child: Text(l10n.productRequestMine),
          ),
      ],
    );
  }
}
