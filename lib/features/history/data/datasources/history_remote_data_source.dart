import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HistoryRemoteDataSource {
  Future<void> addToHistory({
    required String userId,
    required Map<String, dynamic> movie,
  });

  Future<List<Map<String, dynamic>>> getHistory({
    required String userId,
  });
}

class HistoryRemoteDataSourceImpl
    implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  HistoryRemoteDataSourceImpl({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> _historyCollection(
    String userId,
  ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('history');
  }

  @override
  Future<void> addToHistory({
    required String userId,
    required Map<String, dynamic> movie,
  }) async {
    final movieId = movie['id'].toString();

    await _historyCollection(userId)
        .doc(movieId)
        .set({
      ...movie,
      'viewedAt': Timestamp.now(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory({
    required String userId,
  }) async {
    final snapshot = await _historyCollection(userId)
        .orderBy('viewedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }
}