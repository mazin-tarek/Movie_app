import 'package:dartz/dartz.dart';
import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String avatar,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    required String phone,
    required String avatar,
  });

  Future<Either<Failure, void>> deleteAccount();

  Stream<UserEntity?> get authStateChanges;
  UserEntity? getCurrentUser();

  Future<UserEntity?> getCurrentUserWithProfile();

  Future<Either<Failure, void>> forgotPassword({required String email});
}
