import '../../l10n/app_localizations.dart';
import '../error/failure.dart';

/// Turns a [Failure] into a localized, user-facing sentence.
/// Blocs stay free of copy; widgets call `failure.localize(context.l10n)`.
///
/// The API's own `message` is Russian only, so an [ApiFailure] is localized
/// from its `code` — exactly what the API docs recommend — and only falls
/// back to the server text for a code the app does not know yet.
extension FailureL10n on Failure {
  String localize(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    NotFoundFailure() => l10n.errorNotFound,
    CacheFailure() => l10n.errorCache,
    // 502 is the bank or the payment service refusing the payment.
    ServerFailure(statusCode: 502) => l10n.errorPaymentBankFailed,
    ServerFailure() => l10n.errorServer,
    UnknownFailure() => l10n.errorUnknown,
    ApiFailure(:final code) => _localizeCode(code, l10n),
  };

  String _localizeCode(String code, AppLocalizations l10n) => switch (code) {
    ApiCodes.otpRateLimited => l10n.errorOtpRateLimited,
    ApiCodes.otpInvalid => l10n.errorOtpInvalid,
    ApiCodes.otpTooManyAttempts => l10n.errorOtpTooManyAttempts,
    ApiCodes.otpExpired => l10n.errorOtpExpired,
    ApiCodes.userBlocked => l10n.errorUserBlocked,
    ApiCodes.categoryNotFound => l10n.errorNotFound,
    ApiCodes.variantRequired => l10n.errorVariantRequired,
    ApiCodes.preOrderItemsUnavailable => l10n.errorItemsUnavailable,
    ApiCodes.preOrderPriceChanged => l10n.errorPriceChanged,
    ApiCodes.preOrderAvailabilityCheckFailed ||
    'service_unavailable' => l10n.errorSupplierUnavailable,
    ApiCodes.preOrderNotFound => l10n.errorNotFound,
    ApiCodes.invalidPreOrderTransition => l10n.errorCannotCancel,
    ApiCodes.tooManyRequests => l10n.errorTooManyRequests,
    ApiCodes.preOrderAlreadyPaid => l10n.errorPreOrderAlreadyPaid,
    ApiCodes.preOrderNotPayable => l10n.errorPreOrderNotPayable,
    ApiCodes.bankNotFound => l10n.errorBankNotFound,
    ApiCodes.paymentNotFound => l10n.errorNotFound,
    ApiCodes.productRequestInvalidLink => l10n.errorProductRequestInvalidLink,
    ApiCodes.productRequestNotFound => l10n.errorNotFound,
    ApiCodes.imageSearchInvalidImage => l10n.errorImageSearchInvalidImage,
    ApiCodes.imageSearchInProgress => l10n.errorImageSearchInProgress,
    ApiCodes.imageSearchNotFound => l10n.errorNotFound,
    ApiCodes.marketplaceUnavailable => l10n.errorImageSearchUnavailable,
    'validation_error' => l10n.errorValidation,
    _ => l10n.errorServer,
  };
}
