import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);


  @override
  List<Object?> get props => [message];
}

// فشل خاص بمشاكل السيرفر/الشبكة (هنستخدمه مع API لاحقًا)
class ServerFailure extends Failure {
 const  ServerFailure(super.message);
}

// فشل خاص بمشاكل الـ Authentication تحديدًا
class AuthFailure extends Failure {
const  AuthFailure(super.message);
}

// فشل لو مفيش إنترنت أصلاً
class NetworkFailure extends Failure {
const   NetworkFailure(super.message);
}
