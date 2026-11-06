import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../product/domain/entities/product_id.dart';
import '../../../product_request/domain/repositories/product_request_repository.dart';

abstract final class NotificationNavigation {
  /// [productRequestId] comes with the "your product is in the catalog"
  /// push, whose [target] is a slug the product route does not take: the
  /// request is read back for the product's numeric id instead.
  static Future<void> open(
    String? targetType,
    String? target, {
    GoRouter? router,
    String? productRequestId,
  }) async {
    if (target == null || target.isEmpty) return;
    switch (targetType) {
      case 'product':
        final productId =
            ProductId.tryParse(target) ??
            await _productOfRequest(productRequestId);
        if (productId == null) return;
        unawaited(
          (router ?? AppRouter.router).pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': productId.toString()},
          ),
        );
      case 'category':
        unawaited(
          (router ?? AppRouter.router).pushNamed(
            AppRoutes.categoryDetail.name,
            pathParameters: {'id': target},
          ),
        );
      case 'image_search':
        unawaited(
          (router ?? AppRouter.router).pushNamed(
            AppRoutes.imageSearch.name,
            queryParameters: {'id': target},
          ),
        );
      case 'url':
        final uri = Uri.tryParse(target);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
    }
  }

  static Future<int?> _productOfRequest(String? requestId) async {
    final id = int.tryParse(requestId ?? '');
    if (id == null) return null;
    final result = await getIt<ProductRequestRepository>().byId(id);
    return result.dataOrNull?.product?.id;
  }
}
