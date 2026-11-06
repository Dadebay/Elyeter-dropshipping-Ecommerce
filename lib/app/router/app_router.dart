import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions/context_extensions.dart';
import '../../core/di/injector.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../features/address/presentation/view/address_list_page.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/brand/presentation/view/brand_page.dart';
import '../../features/cart/presentation/view/cart_page.dart';
import '../../features/category/presentation/view/category_detail_page.dart';
import '../../features/category/presentation/view/category_page.dart';
import '../../features/favorite/presentation/view/favorite_page.dart';
import '../../features/legal/presentation/view/static_page_view.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/marketplace/presentation/view/marketplace_page.dart';
import '../../features/notification/presentation/view/notification_page.dart';
import '../../features/onboarding/presentation/view/onboarding_page.dart';
import '../../features/order/presentation/view/order_detail_page.dart';
import '../../features/order/presentation/view/order_track_page.dart';
import '../../features/order/presentation/view/checkout_page.dart';
import '../../features/order/presentation/view/all_orders_page.dart';
import '../../features/order/presentation/view/active_orders_page.dart';
import '../../features/product/domain/entities/product_id.dart';
import '../../features/product/presentation/view/product_detail_page.dart';
import '../../features/product/presentation/view/product_reviews_page.dart';
import '../../features/product_request/presentation/view/product_request_list_page.dart';
import '../../features/profile/presentation/view/edit_profile_page.dart';
import '../../features/profile/presentation/view/profile_page.dart';
import '../../features/search/presentation/view/search_page.dart';
import '../../features/search/presentation/view/image_search_page.dart';
import '../../features/search/presentation/widgets/search_reveal_transition.dart';
import '../../features/settings/presentation/view/settings_page.dart';
import '../view/home_shell.dart';
import 'app_routes.dart';

/// Single [GoRouter] instance.
///
/// The five tabs live in a [StatefulShellRoute] so each keeps its own
/// navigation stack and scroll position — tapping Home twice does not reset
/// the Cart tab.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: _initialLocation(),
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home.path,
                name: AppRoutes.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: AppRoutes.productDetail.path,
                    name: AppRoutes.productDetail.name,
                    redirect: (context, state) =>
                        ProductId.tryParse(state.pathParameters['id']) == null
                        ? AppRoutes.home.path
                        : null,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ProductDetailPage(
                      initialVariantId: ProductId.tryParse(
                        state.uri.queryParameters['variant'],
                      ),
                      productId: ProductId.tryParse(
                        state.pathParameters['id'],
                      )!,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.productReviews.path,
                    name: AppRoutes.productReviews.name,
                    redirect: (context, state) =>
                        ProductId.tryParse(state.pathParameters['id']) == null
                        ? AppRoutes.home.path
                        : null,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ProductReviewsPage(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.brand.path,
                    name: AppRoutes.brand.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the display name, so the app bar reads
                    // "Loro Piana" rather than the numeric ID.
                    builder: (context, state) => BrandPage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.categoryDetail.path,
                    name: AppRoutes.categoryDetail.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the display name, so the app bar reads
                    // "Make Up" rather than the slug.
                    builder: (context, state) => CategoryDetailPage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.marketplace.path,
                    name: AppRoutes.marketplace.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the partner's display name so the app
                    // bar reads "AliExpress", not "aliexpress".
                    builder: (context, state) => MarketplacePage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.category.path,
                name: AppRoutes.category.name,
                builder: (context, state) => const CategoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart.path,
                name: AppRoutes.cart.name,
                builder: (context, state) => const CartPage(),
                routes: [
                  GoRoute(
                    path: AppRoutes.checkout.path,
                    name: AppRoutes.checkout.name,
                    // Over the shell: an order being read is not a tab, and
                    // the nav bar would only offer a way to lose it.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const CheckoutPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorite.path,
                name: AppRoutes.favorite.name,
                builder: (context, state) => const FavoritePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile.path,
                name: AppRoutes.profile.name,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  // Active orders and the finished history are separate pages.
                  GoRoute(
                    path: AppRoutes.orders.path,
                    name: AppRoutes.orders.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AllOrdersPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.activeOrders.path,
                    name: AppRoutes.activeOrders.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ActiveOrdersPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.editProfile.path,
                    name: AppRoutes.editProfile.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: AppRoutes.addresses.path,
                    name: AppRoutes.addresses.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AddressListPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.productRequests.path,
                    name: AppRoutes.productRequests.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ProductRequestListPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.notifications.path,
                    name: AppRoutes.notifications.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NotificationPage(
                      title: context.l10n.profileNotifications,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.announcements.path,
                    name: AppRoutes.announcements.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NotificationPage(
                      title: context.l10n.profileAnnouncements,
                      isAnnouncement: true,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.staticPage.path,
                    name: AppRoutes.staticPage.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        StaticPageView(slug: state.pathParameters['slug']!),
                  ),
                  GoRoute(
                    path: AppRoutes.faq.path,
                    name: AppRoutes.faq.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        const StaticPageView(slug: 'faq'),
                  ),
                  GoRoute(
                    path: AppRoutes.terms.path,
                    name: AppRoutes.terms.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        const StaticPageView(slug: 'terms'),
                  ),
                  GoRoute(
                    path: AppRoutes.privacy.path,
                    name: AppRoutes.privacy.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        const StaticPageView(slug: 'privacy'),
                  ),
                  GoRoute(
                    path: AppRoutes.settings.path,
                    name: AppRoutes.settings.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.orderDetail.path,
        name: AppRoutes.orderDetail.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            OrderDetailPage(orderId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.orderTrack.path,
        name: AppRoutes.orderTrack.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            OrderTrackPage(orderId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.imageSearch.path,
        name: AppRoutes.imageSearch.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ImageSearchPage(
          imagePath: state.extra as String?,
          searchId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.search.path,
        name: AppRoutes.search.name,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: SearchFadeTransition.duration,
          reverseTransitionDuration: SearchFadeTransition.reverseDuration,
          child: const SearchPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SearchFadeTransition(animation: animation, child: child),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );

  static String _initialLocation() {
    if (!getIt.isRegistered<LocalStorage>()) return AppRoutes.home.path;
    return getIt<LocalStorage>().getBool(StorageKeys.onboardingSeen) == true
        ? AppRoutes.home.path
        : AppRoutes.onboarding.path;
  }
}
