import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_data_source.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._remote);

  final MarketplaceRemoteDataSource _remote;

  @override
  Future<Result<List<Marketplace>>> list() async {
    try {
      final all = await _remote.list();
      return Success([
        for (final m in all)
          if (m.productsCount > 0) m,
      ]);
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
