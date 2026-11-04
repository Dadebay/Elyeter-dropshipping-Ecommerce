import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_request.dart';
import '../../domain/repositories/product_request_repository.dart';
import '../datasources/product_request_remote_data_source.dart';

class ProductRequestRepositoryImpl implements ProductRequestRepository {
  ProductRequestRepositoryImpl(this._remote);

  final ProductRequestRemoteDataSource _remote;

  @override
  Future<Result<ProductRequest>> create(String text) =>
      _guard(() => _remote.create(text.trim()));

  @override
  Future<Result<Paginated<ProductRequest>>> list({
    int page = 1,
    int size = AppConstants.pageSize,
  }) => _guard(
    () => _remote.list(
      page: page < 1 ? 1 : page,
      size: size.clamp(1, AppConstants.maxPageSize),
    ),
  );

  @override
  Future<Result<ProductRequest>> byId(int id) => _guard(() => _remote.byId(id));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
