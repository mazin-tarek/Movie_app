import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:movieapp/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:movieapp/features/auth/data/models/user_model.dart';
import 'package:movieapp/features/auth/domain/entities/user_entity.dart';
import 'package:movieapp/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  final UserRemoteDatasource _userRemoteDatasource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required UserRemoteDatasource userRemoteDataSource,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _userRemoteDatasource = userRemoteDataSource;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authRemoteDataSource.authStateChanges.asyncExpand((user) async* {
      if (user == null) {
        yield null;
        return;
      }

      yield await _withProfile(user);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authRemoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      await _ensureUserProfile(user);
      return Right(await _withProfile(user));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _authRemoteDataSource.signInWithGoogle();
      await _ensureUserProfile(user);
      return Right(await _withProfile(user));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDataSource.signOut();
      return const Right(null);
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String avatar,
  }) async {
    try {
      final user = await _authRemoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        avatar: avatar,
      );

      await _userRemoteDatasource.saveUserData(
        uid: user.uid,
        name: name,
        phone: phone,
        avatar: avatar,
      );

      final userWithData = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.name,
        phone: phone,
        avatar: avatar,
      );

      return Right(userWithData);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    required String phone,
    required String avatar,
  }) async {
    try {
      final user = _authRemoteDataSource.getCurrentUser();

      if (user == null) {
        return Left(ServerFailure('No authenticated user found.'));
      }

      await _authRemoteDataSource.updateDisplayName(name);

      await _userRemoteDatasource.updateUserData(
        uid: user.uid,
        name: name,
        phone: phone,
        avatar: avatar,
      );
      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        name: name,
        phone: phone,
        avatar: avatar,
      );
      return Right(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _authRemoteDataSource.getCurrentUser();

      if (user != null) {
        await _userRemoteDatasource.deleteUserData(user.uid);
      }

      await _authRemoteDataSource.deleteAccount();
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _authRemoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity?> getCurrentUserWithProfile() async {
    final user = _authRemoteDataSource.getCurrentUser();

    if (user == null) return null;

    return _withProfile(user);
  }

  Future<void> _ensureUserProfile(UserEntity user) async {
    await _userRemoteDatasource.ensureUserData(
      uid: user.uid,
      name: user.name ?? '',
      phone: user.phone ?? '',
      avatar: user.avatar ?? '',
    );
  }

  Future<UserEntity> _withProfile(UserEntity user) async {
    final name = await _userRemoteDatasource.getUserName(user.uid);
    final phone = await _userRemoteDatasource.getUserPhone(user.uid);
    final avatar = await _userRemoteDatasource.getUserAvatar(user.uid);

    if (name == null && phone == null && (avatar == null || avatar.isEmpty)) {
      return user;
    }

    return UserModel(
      uid: user.uid,
      email: user.email,
      name: name ?? user.name,
      phone: phone ?? user.phone,
      avatar: avatar ?? user.avatar,
    );
  }

  String _mapFirebaseErrorToMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is badly formatted.';

      case 'user-disabled':
        return 'This user has been disabled.';

      case 'user-not-found':
        return 'No user found for that email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'operation-not-allowed':
        return 'This sign-in method is currently unavailable.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'No internet connection. Please check your connection.';

      case 'user-mismatch':
        return 'The account does not match the current user.';

      case 'requires-recent-login':
        return 'Please sign in again to continue.';

      case 'credential-already-in-use':
        return 'This account is already associated with another user.';
      case 'sign-in-cancelled':
        return 'Google sign-in was cancelled.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _authRemoteDataSource.forgetPassword(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseErrorToMessage(e.code)));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
