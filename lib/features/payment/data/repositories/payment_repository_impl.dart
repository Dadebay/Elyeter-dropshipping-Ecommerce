import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<Result<List<Bank>>> banks() => _guard(_remote.banks);

  @override
  Future<Result<Payment>> start({
    required int preOrderId,
    required int bankId,
  }) => _guard(() => _remote.start(preOrderId: preOrderId, bankId: bankId));

  @override
  Future<Result<Payment>> byId(int id) => _guard(() => _remote.byId(id));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
