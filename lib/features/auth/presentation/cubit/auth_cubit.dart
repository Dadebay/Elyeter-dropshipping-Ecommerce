import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Who is signed in, app-wide.
class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.failure});

  final AuthStatus status;
  final AppUser? user;

  /// Set when the session ended on its own — an expired token or a blocked
  /// account — so the login screen can say why.
  final Failure? failure;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, failure];
}

/// Owns the session: restores it on launch, holds the signed-in user and
/// clears everything when the backend says the token is gone.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Runs at startup. A stored token may still be expired — `/auth/me` is
  /// what proves it, and a 401 there logs the customer out immediately.
  Future<void> restore() async {
    if (!await _repository.hasSession()) {
      return emit(const AuthState(status: AuthStatus.unauthenticated));
    }

    final result = await _repository.currentUser();
    switch (result) {
      case Success(:final data):
        emit(AuthState(status: AuthStatus.authenticated, user: data));
      case Error(:final failure):
        // A network hiccup at launch must not sign a valid session out;
        // only the backend rejecting the token does that, and the
        // interceptor has already cleared it by then.
        if (failure.statusCode == 401 || failure.code == ApiCodes.userBlocked) {
          emit(AuthState(status: AuthStatus.unauthenticated, failure: failure));
        } else {
          emit(const AuthState(status: AuthStatus.authenticated));
        }
    }
  }

  /// Called by the login flow once `/auth/verify-code` succeeds.
  void onSignedIn(AppUser user) =>
      emit(AuthState(status: AuthStatus.authenticated, user: user));

  void onUserUpdated(AppUser user) =>
      emit(AuthState(status: AuthStatus.authenticated, user: user));

  /// The token was refused mid-session (401, or 403 `user-blocked`).
  void onSessionExpired(Failure failure) =>
      emit(AuthState(status: AuthStatus.unauthenticated, failure: failure));

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// `DELETE /auth/me`
  Future<Failure?> deleteAccount() async {
    final result = await _repository.deleteAccount();
    return result.fold((_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return null;
    }, (failure) => failure);
  }
}
