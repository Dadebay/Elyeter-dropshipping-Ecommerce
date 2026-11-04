import 'dart:ui' show PlatformDispatcher;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_notifications_service.dart';
import '../services/push_service.dart';
import '../../app/cubit/locale_cubit.dart';
import '../../app/cubit/theme_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/brand/data/datasources/brand_remote_data_source.dart';
import '../../features/brand/data/repositories/brand_repository_impl.dart';
import '../../features/brand/domain/repositories/brand_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/category/data/datasources/category_remote_data_source.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../../features/order/data/datasources/pre_order_remote_data_source.dart';
import '../../features/order/data/repositories/pre_order_repository_impl.dart';
import '../../features/order/domain/repositories/pre_order_repository.dart';
import '../../features/payment/data/datasources/payment_remote_data_source.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product_request/data/datasources/product_request_remote_data_source.dart';
import '../../features/product_request/data/repositories/product_request_repository_impl.dart';
import '../../features/product_request/domain/repositories/product_request_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/search/data/datasources/image_search_remote_data_source.dart';
import '../../features/search/data/repositories/image_search_repository_impl.dart';
import '../../features/search/domain/repositories/image_search_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../constants/app_environment.dart';
import '../network/api_client.dart';
import '../network/shop_api.dart';
import '../network/interceptors/api_log_interceptor.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/language_interceptor.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Service locator. One `getIt` for the whole app.
final getIt = GetIt.instance;

/// Registration order: external packages -> core services -> feature layers.
///
/// Feature registrations live in their own `_registerX()` function below so
/// each feature stays self-contained and easy to move when the codebase
/// migrates to MVVM.
Future<void> configureDependencies() async {
  await _registerExternal();
  _registerCore();
  _registerGlobalCubits();
  _registerFeatures();
}

Future<void> _registerExternal() async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        // v11 encrypts with AES-GCM by default; only the iOS class needs setting.
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    )
    ..registerLazySingleton<Connectivity>(Connectivity.new);
}

void _registerCore() {
  getIt
    ..registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorageImpl(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()),
    )
    ..registerLazySingleton<Dio>(
      () => ApiClient.createDio(
        interceptors: [
          AuthInterceptor(
            getIt<SecureStorage>(),
            // Looked up lazily: the cubit is registered after Dio, and a
            // token is only ever refused once a request is in flight.
            onUnauthorized: (failure) =>
                getIt<AuthCubit>().onSessionExpired(failure),
          ),
          LanguageInterceptor(
            getIt<LocalStorage>(),
            languageCode: () =>
                getIt<LocaleCubit>().state?.languageCode ??
                PlatformDispatcher.instance.locale.languageCode,
          ),
          if (AppEnvironment.enableLogging) ApiLogInterceptor(),
        ],
      ),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()))
    ..registerLazySingleton<ShopApi>(() => ShopApi(getIt<ApiClient>()));
}

void _registerGlobalCubits() {
  getIt
    ..registerLazySingleton<ThemeCubit>(ThemeCubit.new)
    ..registerLazySingleton<LocaleCubit>(LocaleCubit.new);
}

void _registerFeatures() {
  // Favourites and the cart are read and written from several tabs, so these
  // cubits outlive any one page — singletons rather than per-page factories.
  getIt
    ..registerLazySingleton<FavoriteCubit>(
      () => FavoriteCubit(getIt<ShopApi>(), getIt<AuthCubit>()),
    )
    ..registerLazySingleton<CartCubit>(CartCubit.new)
    ..registerLazySingleton<ProfileCubit>(ProfileCubit.new);

  _registerAuth();
  _registerCatalog();
  _registerPreOrders();
}

/// SMS login, the session and the account endpoints.
void _registerAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<SecureStorage>(),
      ),
    )
    // One session for the whole app; the interceptor reaches for it too.
    ..registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    // One per login screen: it owns a resend countdown.
    ..registerFactory<LoginCubit>(
      () => LoginCubit(getIt<AuthRepository>(), getIt<AuthCubit>()),
    )
    // Push rides on the session: the topic is joined by everyone, but the
    // device token is only worth sending once an account exists.
    ..registerLazySingleton<LocalNotificationsService>(
      LocalNotificationsService.new,
    )
    ..registerLazySingleton<PushService>(
      () => PushService(
        getIt<AuthRepository>(),
        getIt<LocalNotificationsService>(),
        getIt<LocaleCubit>(),
        getIt<AuthCubit>(),
      ),
    );
}

/// Categories, products, brands and the type-ahead search.
void _registerCatalog() {
  getIt
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt<CategoryRemoteDataSource>()),
    )
    // One per page: the tab's cubit dies with the page, while the tree it
    // loaded stays cached in the repository.
    ..registerFactory<CategoryCubit>(
      () => CategoryCubit(getIt<CategoryRepository>()),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
    )
    ..registerLazySingleton<BrandRemoteDataSource>(
      () => BrandRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<BrandRepository>(
      () => BrandRepositoryImpl(getIt<BrandRemoteDataSource>()),
    )
    ..registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(
        getIt<SearchRemoteDataSource>(),
        getIt<LocalStorage>(),
      ),
    )
    ..registerLazySingleton<MarketplaceRemoteDataSource>(
      () => MarketplaceRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(getIt<MarketplaceRemoteDataSource>()),
    )
    ..registerLazySingleton<ImageSearchRemoteDataSource>(
      () => ImageSearchRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<ImageSearchRepository>(
      () => ImageSearchRepositoryImpl(getIt<ImageSearchRemoteDataSource>()),
    )
    // "Didn't find a product? Send us a link".
    ..registerLazySingleton<ProductRequestRemoteDataSource>(
      () => ProductRequestRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<ProductRequestRepository>(
      () =>
          ProductRequestRepositoryImpl(getIt<ProductRequestRemoteDataSource>()),
    );
}

/// The cart lives on the device; these are the two supplier-backed calls
/// and the order history behind them.
void _registerPreOrders() {
  getIt
    ..registerLazySingleton<PreOrderRemoteDataSource>(
      () => PreOrderRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<PreOrderRepository>(
      () => PreOrderRepositoryImpl(getIt<PreOrderRemoteDataSource>()),
    )
    // Online card payment for a placed pre-order.
    ..registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(getIt<PaymentRemoteDataSource>()),
    );
}
