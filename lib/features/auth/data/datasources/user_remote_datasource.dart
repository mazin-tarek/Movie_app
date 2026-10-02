import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRemoteDatasource {
  Future<void> saveUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  });

  Future<void> updateUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  });

  Future<String?> getUserPhone(String uid);

  Future<String?> getUserName(String uid);

  Future<String?> getUserAvatar(String uid);

  Future<void> ensureUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  });

  Future<void> deleteUserData(String uid);
}

class UserRemoteDataSourceImpl implements UserRemoteDatasource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<String?> getUserPhone(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['phone'] as String?;
  }

  @override
  Future<String?> getUserName(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['name'] as String?;
  }

  @override
  Future<String?> getUserAvatar(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['avatar'] as String?;
  }

  @override
  Future<void> ensureUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'name': name,
        'phone': phone,
        'avatar': avatar,
      });
    }
  }

  @override
  Future<void> deleteUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final subcollections = ['watchlist', 'history'];

    for (final name in subcollections) {
      final snapshot = await userRef.collection(name).get();
      if (snapshot.docs.isEmpty) continue;

      for (var i = 0; i < snapshot.docs.length; i += 400) {
        final batch = _firestore.batch();
        final end = i + 400 > snapshot.docs.length ? snapshot.docs.length : i + 400;
        for (final doc in snapshot.docs.sublist(i, end)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }

    await userRef.delete();
  }

  @override
  Future<void> saveUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'avatar': avatar,
    });
  }

  @override
  Future<void> updateUserData({
    required String uid,
    required String name,
    required String phone,
    required String avatar,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'avatar': avatar,
    }, SetOptions(merge: true));
  }
}
