import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/shop_api.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Signed-in account's server favourites. Never persisted across accounts.
class FavoriteCubit extends Cubit<Set<String>> {
  FavoriteCubit([this._api, this._auth]) : super(const {}) {
    if (_auth case final auth?) {
      _subscription = auth.stream.listen(_onAuthChanged);
      _onAuthChanged(auth.state);
    }
  }

  final ShopApi? _api;
  final AuthCubit? _auth;
  StreamSubscription<AuthState>? _subscription;
  int _generation = 0;
  int? _accountId;
  bool _authenticated = false;
  final Set<String> _pending = {};
  final StreamController<void> _synced = StreamController<void>.broadcast();

  /// Fires once the server has accepted a heart tap, so a list built from the
  /// favourites endpoint knows it is worth fetching again.
  Stream<void> get synced => _synced.stream;

  bool contains(String id) => state.contains(id);

  void _onAuthChanged(AuthState auth) {
    if (_authenticated == auth.isAuthenticated && _accountId == auth.user?.id) {
      return;
    }
    _authenticated = auth.isAuthenticated;
    _accountId = auth.user?.id;
    ++_generation;
    emit(const {});
    if (auth.isAuthenticated) unawaited(refresh());
  }

  Future<void> refresh() async {
    if (_auth?.state.isAuthenticated != true || _api == null) return;
    final generation = _generation;
    try {
      final ids = await _api.favoriteIds();
      if (!isClosed && generation == _generation) {
        for (final pending in _pending) {
          if (state.contains(pending)) {
            ids.add(pending);
          } else {
            ids.remove(pending);
          }
        }
        emit(ids);
      }
    } on Object {
      // A failed refresh must leave any optimistic hearts intact.
    }
  }

  Future<bool> toggle(String id) async {
    final productId = int.tryParse(id);
    if (_api == null && _auth == null) {
      final next = Set<String>.of(state);
      if (!next.remove(id)) next.add(id);
      emit(next);
      return true;
    }
    if (_auth?.state.isAuthenticated != true ||
        productId == null ||
        !_pending.add(id)) {
      return false;
    }
    final wasFavorite = state.contains(id);
    final generation = _generation;
    final optimistic = Set<String>.of(state);
    if (wasFavorite) {
      optimistic.remove(id);
    } else {
      optimistic.add(id);
    }
    emit(optimistic);
    try {
      final actual = await _api!.setFavorite(productId, favorite: !wasFavorite);
      if (!isClosed && generation == _generation) {
        final reconciled = Set<String>.of(state);
        if (actual) {
          reconciled.add(id);
        } else {
          reconciled.remove(id);
        }
        emit(reconciled);
        if (!_synced.isClosed) _synced.add(null);
      }
      return true;
    } on Object {
      if (!isClosed && generation == _generation) {
        final rollback = Set<String>.of(state);
        if (wasFavorite) {
          rollback.add(id);
        } else {
          rollback.remove(id);
        }
        emit(rollback);
      }
      return false;
    } finally {
      _pending.remove(id);
    }
  }

  void removeAll() => emit(const {});

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _synced.close();
    await super.close();
  }
}
