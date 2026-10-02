import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? avatar;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
    required this.phone,
    this.avatar,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        phone,
        avatar,
      ];
}