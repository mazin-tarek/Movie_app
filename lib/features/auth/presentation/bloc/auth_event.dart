import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String avatar;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.avatar,
  });

  @override
  List<Object> get props => [email, password, name, phone, avatar];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String phone;
  final String avatar;

  const UpdateProfileRequested({
    required this.name,
    required this.phone,
    required this.avatar,
  });

  @override
  List<Object> get props => [name, phone, avatar];
}

class DeleteAccountRequested extends AuthEvent {}
