import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:movieapp/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.name,
    super.phone,
    super.avatar,
  });

  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? avatar,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      phone: firebaseUser.phoneNumber,
      avatar: avatar,
    );
  }

  UserModel copyWithPhone(String? phone) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
    );
  }

  UserModel copyWithAvatar(String? avatar) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
    );
  }
}