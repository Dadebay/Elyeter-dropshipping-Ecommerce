import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/entities/pre_order_check.dart';
import '../../domain/entities/pre_order_line.dart';
import '../../domain/repositories/pre_order_repository.dart';
import '../datasources/pre_order_remote_data_source.dart';
import '../models/pre_order_check_model.dart';

class PreOrderRepositoryImpl implements PreOrderRepository {
  PreOrderRepositoryImpl(this._remote) {
    // Lets a 409's `details` be read back as a check result without the
    // domain layer importing a data model.
    PreOrderCheckDetails.register(PreOrderCheckModel.fromJson);
  }

  final PreOrderRemoteDataSource _remote;

  @override
  Future<Result<PreOrderCheck>> check(List<PreOrderLine> lines) =>
      _guard(() => _remote.check(_trim(lines)));

  @override
  Future<Result<PreOrder>> create({
    required List<PreOrderLine> lines,
    String? customerName,
    String? address,
    String? comment,
    num? expectedTotal,
    int? locationId,
    String? idempotencyKey,
  }) => _guard(
    () => _remote.create(
      lines: _trim(lines),
      customerName: customerName,
      address: address,
      comment: comment,
      expectedTotal: expectedTotal,
      locationId: locationId,
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Result<Paginated<PreOrder>>> list({
    int page = 1,
    int size = AppConstants.pageSize,
    List<PreOrderStatus> statuses = const [],
  }) => _guard(
    () => _remote.list(
      page: page < 1 ? 1 : page,
      size: size.clamp(1, AppConstants.maxPageSize),
      statuses: statuses,
    ),
  );

  @override
  Future<Result<PreOrder>> byId(int id) => _guard(() => _remote.byId(id));

  @override
  Future<Result<PreOrder>> cancel(int id) => _guard(() => _remote.cancel(id));

  /// The API takes at most 30 lines and 1-99 of each; sending more is a 400.
  List<PreOrderLine> _trim(List<PreOrderLine> lines) => [
    for (final line in lines.take(AppConstants.maxCartLines))
      PreOrderLine(
        productId: line.productId,
        variantId: line.variantId,
        quantity: line.quantity.clamp(1, AppConstants.maxLineQuantity),
        price: line.price,
      ),
  ];

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
