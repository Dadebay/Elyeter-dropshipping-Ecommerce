import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../../product/presentation/widgets/product_grid_shimmer.dart';
import '../widgets/photo_search_launcher.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../product_request/presentation/widgets/product_request_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  SearchSuggestions _suggestions = SearchSuggestions.empty;
  Failure? _suggestionFailure;
  Failure? _productFailure;
  String? _submitted;
  int _request = 0;
  Animation<double>? _routeAnimation;
  bool _initialFocusRequested = false;

  bool get _showError => _suggestionFailure != null || _productFailure != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (_routeAnimation != animation) {
      _routeAnimation?.removeStatusListener(_onRouteStatus);
      _routeAnimation = animation;
      _routeAnimation?.addStatusListener(_onRouteStatus);
    }
    if (animation == null || animation.status == AnimationStatus.completed) {
      _focusAfterEntrance();
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _focusAfterEntrance();
    } else if (status == AnimationStatus.reverse) {
      _focusNode.unfocus();
    }
  }

  void _focusAfterEntrance() {
    // Flutter briefly reports a completed animation while measuring the
    // offstage route for Hero transitions; that is not the visible entrance.
    if (_initialFocusRequested || ModalRoute.of(context)?.offstage == true) {
      return;
    }
    _initialFocusRequested = true;
    // Let the page settle before the keyboard resizes its body.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route?.isCurrent == false || route?.offstage == true) return;
      _focusNode.requestFocus();
    });
  }

  void _close() {
    _focusNode.unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home.name);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    final query = value.trim();
    final request = ++_request;
    setState(() {
      _submitted = null;
      _suggestions = SearchSuggestions.empty;
      _suggestionFailure = null;
      _productFailure = null;
    });
    if (query.length < 2) return;
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _loadSuggestions(query, request),
    );
  }

  Future<void> _loadSuggestions(String query, int request) async {
    final result = await getIt<SearchRepository>().suggest(query);
    if (!mounted || request != _request) return;
    if (result.failureOrNull != null) _focusNode.unfocus();
    setState(() {
      _suggestions = result.dataOrNull ?? SearchSuggestions.empty;
      _suggestionFailure = result.failureOrNull;
    });
  }

  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _debounce?.cancel();
    ++_request;
    getIt<SearchRepository>().remember(query);
    _focusNode.unfocus();
    setState(() {
      _submitted = query;
      _suggestionFailure = null;
      _productFailure = null;
    });
  }

  Future<void> _searchByPhoto() {
    _focusNode.unfocus();
    return startPhotoSearch(context);
  }

  void _clear() {
    _controller.clear();
    _changed('');
    _focusNode.requestFocus();
  }

  void _retry() {
    if (_productFailure != null) {
      setState(() => _productFailure = null);
      return; // Remounting the product grid starts its request again.
    }
    final query = _controller.text.trim();
    if (query.length < 2) return;
    setState(() => _suggestionFailure = null);
    _loadSuggestions(query, ++_request);
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight + AppSpacing.sm,
        leadingWidth: _showError ? AppBackButton.leadingWidth : null,
        leading: _showError
            ? Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: AppBackButton.appBarLeading(onPressed: _close),
              )
            : null,
        title: _showError
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: _searchHeader(),
              ),
      ),
      body: SafeArea(
        top: false,
        child: SizedBox.expand(key: const Key('search-panel'), child: _body()),
      ),
    );
  }

  Widget _backButton() => IconButton(
    tooltip: context.l10n.commonClose,
    onPressed: _close,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints.tightFor(width: 48, height: 48),
    icon: Icon(Icons.arrow_back, size: 20, color: context.colors.onSurface),
  );

  Widget _searchHeader() {
    final hasText = _controller.text.isNotEmpty;
    final surface = context.isDark
        ? AppColors.surfaceDark
        : const Color(0xFFF1F1F3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.xl, 0),
      child: Row(
        children: [
          _backButton(),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                key: const Key('search-input'),
                controller: _controller,
                focusNode: _focusNode,
                textAlignVertical: TextAlignVertical.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.homeSearchHint,
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    color: context.isDark
                        ? AppColors.grey300
                        : AppColors.iconSoft,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: surface,
                  // Keep the painted pill 48 px tall even without a suffix.
                  isDense: false,
                  contentPadding: EdgeInsets.only(left: 18, right: 4),
                  suffixIconConstraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  suffixIcon: !hasText
                      ? IconButton(
                          tooltip: context.l10n.visualSearchTitle,
                          onPressed: _searchByPhoto,
                          icon: HugeIcon(
                            icon: AppIcons.camera,
                            size: 22,
                            color: context.colors.onSurfaceVariant,
                          ),
                        )
                      : IconButton(
                          tooltip: context.l10n.searchClear,
                          onPressed: _clear,
                          icon: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? AppColors.grey700
                                  : AppColors.grey300.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                  border: _fieldBorder,
                  enabledBorder: _fieldBorder,
                  focusedBorder: _fieldBorder,
                ),
                textInputAction: TextInputAction.search,
                onChanged: _changed,
                onSubmitted: _search,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    borderSide: BorderSide.none,
  );

  Widget _body() {
    final failure = _productFailure ?? _suggestionFailure;
    if (failure != null) {
      return _SearchStatusView.error(failure: failure, onRetry: _retry);
    }
    if (_submitted != null) {
      return CatalogProductGrid(
        key: ValueKey(_submitted),
        query: ProductQuery(search: _submitted),
        loadingState: const ProductGridShimmer(),
        loadingMoreState: const ProductGridShimmer.more(),
        emptyState: const _SearchStatusView.notFound(),
        onInitialFailureChanged: (failure) {
          if (mounted && failure != _productFailure) {
            setState(() => _productFailure = failure);
          }
        },
      );
    }
    final query = _controller.text.trim();
    final normalizedQuery = query.toLowerCase();
    final recent = _uniqueTerms(
      getIt<SearchRepository>().recentSearches(),
    ).where((term) => term.toLowerCase().contains(normalizedQuery)).toList();
    // Pills are the user's actual searches, never product titles added by
    // merely typing. Selecting a phrase opens the same catalogue as Submit.
    final terms = query.isEmpty
        ? const <String>[]
        : _uniqueTerms([
            ...recent,
            ..._suggestions.products.map((product) => product.name),
            ..._suggestions.categories.map((category) => category.name),
          ]).take(10).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (recent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 14),
            child: Wrap(
              key: const Key('search-suggestion-chips'),
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final term in recent.take(6))
                  _SuggestionChip(label: term, onTap: () => _search(term)),
              ],
            ),
          ),
        for (final term in terms)
          _SuggestionRow(
            key: ValueKey('search-term-$term'),
            label: term,
            onTap: () => _search(term),
          ),
      ],
    );
  }

  Iterable<String> _uniqueTerms(Iterable<String> values) sync* {
    final seen = <String>{};
    for (final value in values) {
      final term = value.trim();
      if (term.isNotEmpty && seen.add(term.toLowerCase())) yield term;
    }
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
    borderRadius: BorderRadius.circular(AppRadius.pill),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
      ),
    ),
  );
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
        ),
      ),
      Divider(
        height: 1,
        thickness: 1,
        color: context.colors.outlineVariant.withValues(alpha: 0.4),
      ),
    ],
  );
}

class _SearchStatusView extends StatelessWidget {
  const _SearchStatusView.notFound() : failure = null, onRetry = null;

  const _SearchStatusView.error({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isNotFound = failure == null;
    final connectionError =
        failure is NetworkFailure || failure is TimeoutFailure;
    final title = isNotFound
        ? context.l10n.searchNotFoundTitle
        : connectionError
        ? context.l10n.searchConnectionErrorTitle
        : context.l10n.searchErrorTitle;
    final message = isNotFound
        ? context.l10n.searchNotFoundMessage
        : connectionError
        ? context.l10n.searchConnectionErrorMessage
        : context.l10n.searchErrorMessage;
    final icon = isNotFound
        ? AppAssets.iconSearchNotFound
        : connectionError
        ? AppAssets.iconSearchConnectionError
        : AppAssets.iconSearchError;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isNotFound ? 280 : 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: isNotFound ? 64 : 56,
              height: isNotFound ? 64 : 56,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: isNotFound ? 24 : 20,
                fontWeight: FontWeight.w700,
                color: isNotFound
                    ? (context.isDark ? AppColors.white : AppColors.ink)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: isNotFound ? 16 : 14,
                color: isNotFound
                    ? (context.isDark ? AppColors.grey300 : AppColors.grey700)
                    : context.colors.onSurfaceVariant,
                height: isNotFound ? 1.45 : 1.4,
              ),
            ),
            if (isNotFound) ...[
              const SizedBox(height: 28),
              TextButton(
                onPressed: () => openProductRequestSheet(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(92, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
                child: Text(context.l10n.productRequestSearchAction),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 36),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(92, 40),
                  backgroundColor: context.isDark
                      ? AppColors.surfaceDark
                      : AppColors.grey100,
                  foregroundColor: context.colors.onSurface,
                  shape: const StadiumBorder(),
                ),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
    if (isNotFound) {
      return Align(alignment: const Alignment(0, -0.18), child: content);
    }
    return Center(
      child: Transform.translate(offset: const Offset(0, -100), child: content),
    );
  }
}
