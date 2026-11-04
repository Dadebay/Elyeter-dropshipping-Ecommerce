import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/image_search.dart';
import '../../domain/repositories/image_search_repository.dart';
import '../datasources/image_search_remote_data_source.dart';

class ImageSearchRepositoryImpl implements ImageSearchRepository {
  ImageSearchRepositoryImpl(this._remote);

  final ImageSearchRemoteDataSource _remote;

  @override
  Future<Result<ImageSearch>> create(String path) =>
      _guard(() => _remote.create(path));

  @override
  Future<Result<ImageSearch>> byId(int id) => _guard(() => _remote.byId(id));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
