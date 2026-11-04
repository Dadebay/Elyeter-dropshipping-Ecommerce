import '../../../../core/utils/result.dart';
import '../entities/marketplace.dart';

abstract interface class MarketplaceRepository {
  /// `GET /marketplaces` — public. Marketplaces with no products are left
  /// out, since there is nothing to open.
  Future<Result<List<Marketplace>>> list();
}
