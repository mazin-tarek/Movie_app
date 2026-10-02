import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movieapp/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String avatar,
  });
  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> updateDisplayName(String name);

  Future<void> deleteAccount();

  Stream<UserModel?> get authStateChanges;
  UserModel? getCurrentUser();

  Future<void> forgetPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(credential.user!);
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String avatar,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();

    final updatedUser = _firebaseAuth.currentUser!;

    return UserModel.fromFirebaseUser(updatedUser, avatar: avatar);
  }
bool _googleSignInInitialized = false;

@override
Future<UserModel> signInWithGoogle() async {
  if (!_googleSignInInitialized) {
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  final GoogleSignInAccount googleUser;

  try {
    googleUser = await _googleSignIn.authenticate();
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      throw firebase_auth.FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Sign in cancelled',
      );
    }

    rethrow;
  }

  final googleAuth = googleUser.authentication;

  final credential = firebase_auth.GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  final userCredential = await _firebaseAuth.signInWithCredential(
    credential,
  );

  return UserModel.fromFirebaseUser(
    userCredential.user!,
  );
}

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    await _firebaseAuth.currentUser?.updateDisplayName(name);
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  @override
  UserModel? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
