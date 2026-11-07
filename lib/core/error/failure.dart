import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Domain-level error. Everything above the data layer speaks in [Failure]s.
///
/// [code] is a stable key the presentation layer maps to a localized string,
/// so error text never has to be hard-coded in a bloc. For failures that came
/// off the wire it is the backend's own `code` when there was one
/// (`otp-invalid`, `pre-order-price-changed`, …), which is what the API docs
/// tell clients to branch on.
sealed class Failure extends Equatable {
  const Failure({
    required this.code,
    this.message,
    this.statusCode,
    this.details,
  });

  final String code;
  final String? message;
  final int? statusCode;

  /// Structured extra data — on the pre-order 409s this is a full
  /// `/check`-shaped result the cart can re-render from.
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [code, message, statusCode, details];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode})
    : super(code: 'server_error');
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message}) : super(code: 'network_error');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message}) : super(code: 'timeout_error');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message})
    : super(code: 'unauthorized_error', statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message}) : super(code: 'not_found_error');
}

class CacheFailure extends Failure {
  const CacheFailure({super.message}) : super(code: 'cache_error');
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message}) : super(code: 'unknown_error');
}

/// A documented backend error: [code] is the API's own code, so a bloc can
/// switch on [ApiCodes] and the widget can map it to its own copy instead of
/// showing the Russian `message`.
class ApiFailure extends Failure {
  const ApiFailure({
    required super.code,
    super.message,
    super.statusCode,
    super.details,
    this.errors = const [],
  });

  /// Only on 400 validation failures: one entry per invalid field.
  final List<String> errors;

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Every `code` the app can encounter, from the API's error reference.
abstract final class ApiCodes {
  static const otpRateLimited = 'otp-rate-limited';
  static const otpInvalid = 'otp-invalid';
  static const otpTooManyAttempts = 'otp-too-many-attempts';
  static const otpExpired = 'otp-expired';
  static const userBlocked = 'user-blocked';
  static const categoryNotFound = 'category-not-found';
  static const variantRequired = 'variant-required';
  static const preOrderItemsUnavailable = 'pre-order-items-unavailable';
  static const preOrderPriceChanged = 'pre-order-price-changed';
  static const preOrderAvailabilityCheckFailed =
      'pre-order-availability-check-failed';
  static const preOrderNotFound = 'pre-order-not-found';
  static const invalidPreOrderTransition = 'invalid-pre-order-transition';
  static const tooManyRequests = 'too-many-requests';
  static const preOrderInProgress = 'pre-order-in-progress';
  static const preOrderPaymentInProgress = 'pre-order-payment-in-progress';
  static const preOrderAlreadyPaid = 'pre-order-already-paid';
  static const preOrderNotPayable = 'pre-order-not-payable';
  static const bankNotFound = 'bank-not-found';
  static const paymentNotFound = 'payment-not-found';
  static const productRequestInvalidLink = 'product-request-invalid-link';
  static const productRequestNotFound = 'product-request-not-found';
  static const imageSearchInvalidImage = 'image-search-invalid-image';
  static const imageSearchInProgress = 'image-search-in-progress';
  static const imageSearchNotFound = 'image-search-not-found';
  static const marketplaceUnavailable = 'marketplace-unavailable';
}

extension AppExceptionToFailure on AppException {
  /// Single place where data-layer exceptions become domain failures.
  ///
  /// A response that carried a backend `code` keeps it, so the presentation
  /// layer never has to read `message` to know what happened.
  Failure toFailure() {
    final backendCode = code;
    if (backendCode != null) {
      return ApiFailure(
        code: backendCode,
        message: message,
        statusCode: statusCode,
        details: details,
        errors: switch (this) {
          ValidationException(:final errors) => errors,
          _ => const [],
        },
      );
    }

    return switch (this) {
      NetworkException() => NetworkFailure(message: message),
      TimeoutException() => TimeoutFailure(message: message),
      UnauthorizedException() => UnauthorizedFailure(message: message),
      ForbiddenException() => UnauthorizedFailure(message: message),
      NotFoundException() => NotFoundFailure(message: message),
      CacheException() => CacheFailure(message: message),
      ParsingException() => UnknownFailure(message: message),
      ValidationException(:final errors) => ApiFailure(
        code: 'validation_error',
        message: message,
        statusCode: 400,
        errors: errors,
      ),
      ConflictException() => ApiFailure(
        code: 'conflict',
        message: message,
        statusCode: 409,
        details: details,
      ),
      RateLimitException() => ApiFailure(
        code: ApiCodes.tooManyRequests,
        message: message,
        statusCode: 429,
      ),
      ServiceUnavailableException() => ApiFailure(
        code: 'service_unavailable',
        message: message,
        statusCode: 503,
      ),
      ServerException() => ServerFailure(
        message: message,
        statusCode: statusCode,
      ),
    };
  }
}
