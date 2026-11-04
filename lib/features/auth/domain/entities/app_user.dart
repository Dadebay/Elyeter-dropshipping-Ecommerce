import 'package:equatable/equatable.dart';

/// The signed-in account, as `/auth/me` and the login response return it.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.phone,
    this.username,
    this.image,
    this.fcmToken,
    this.isBlocked = false,
    this.createdAt,
    this.lastLoginAt,
  });

  final int id;

  /// Always `+993XXXXXXXX`; the pre-order endpoints take it from here rather
  /// than from the request body.
  final String phone;

  final String? username;
  final String? image;
  final String? fcmToken;
  final bool isBlocked;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  /// What the profile header shows when the customer has not set a name.
  String get displayName =>
      (username?.trim().isNotEmpty ?? false) ? username!.trim() : phone;

  @override
  List<Object?> get props => [
    id,
    phone,
    username,
    image,
    fcmToken,
    isBlocked,
    createdAt,
    lastLoginAt,
  ];
}
