import 'package:equatable/equatable.dart';

/// A bank the customer can pay through.
class Bank extends Equatable {
  const Bank({required this.id, required this.name, this.logo});

  final int id;
  final String name;

  /// A storage path, like brand logos — resolve it with `MediaUrl`.
  final String? logo;

  @override
  List<Object?> get props => [id, name, logo];
}
