import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/elyeter_shimmer.dart';
import '../../domain/entities/category.dart';
import '../cubit/category_cubit.dart';
import '../widgets/category_grid_tile.dart';

/// The Category tab: every department as a square card, from
/// `GET /categories/tree`.
///
/// Cards without artwork yet are drawn as shimmering wordmarks rather than
/// blank boxes, so a half-loaded grid still looks deliberate.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => getIt<CategoryCubit>()..load(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  /// Slots kept in the grid while the catalog loads.
  static const _placeholderCount = 17;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          // A failure with nothing cached is the only case worth a whole
          // screen; a retry that fails over a grid already on display keeps
          // the grid.
          final failure = state.failure;
          if (failure != null && state.categories.isEmpty) {
            return AppErrorView(
              failure: failure,
              onRetry: () => context.read<CategoryCubit>().load(),
            );
          }

          final items = [
            for (final category in state.categories) _itemFor(category),
          ];
          // Only the first load shows placeholders; once the tree is in,
          // the grid is exactly as long as the catalog.
          final placeholders = state.isLoading && items.isEmpty
              ? _placeholderCount
              : 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                titleSpacing: AppSpacing.page,

                title: Text(
                  context.l10n.categoryTitle,
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  // Clearance for the floating navigation bar.
                  120,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => index < items.length
                        ? CategoryGridTile(
                            item: items[index],
                            // The detail page reads its title off `extra`,
                            // so the app bar says "Elektronika", not the slug.
                            onTap: () => context.pushNamed(
                              AppRoutes.categoryDetail.name,
                              pathParameters: {'id': items[index].id},
                              extra: items[index].name,
                            ),
                          )
                        : const ElyeterShimmerBox(),
                    childCount: items.length + placeholders,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Routing is by slug, which is what `GET /categories/:slug` takes.
  CategoryGridItem _itemFor(Category category) => CategoryGridItem(
    id: category.slug,
    name: category.name,
    // The small image is the one sized for a grid cell; the large one is
    // the only fallback the API offers.
    imageUrl: category.imageSmall ?? category.imageLarge,
  );
}
