import 'package:cloud_firestore/cloud_firestore.dart';

abstract class WatchlistRemoteDataSource {
  Future<void> addToWatchlist({
    required String userId,
    required Map<String, dynamic> movie,
  });

  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  });

  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  });

  Future<List<Map<String, dynamic>>> getWatchlist({
    required String userId,
  });
}

class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final FirebaseFirestore firestore;

  WatchlistRemoteDataSourceImpl({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> _watchlistCollection(
    String userId,
  ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist');
  }

  @override
  Future<void> addToWatchlist({
    required String userId,
    required Map<String, dynamic> movie,
  }) async {
    final movieId = movie['id'].toString();

  await _watchlistCollection(userId)
    .doc(movieId)
    .set({
  ...movie,
  'addedAt': Timestamp.now(),
});
  }

  @override
  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  }) async {
    await _watchlistCollection(userId)
        .doc(movieId.toString())
        .delete();
  }

  @override
  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  }) async {
    final doc = await _watchlistCollection(userId)
        .doc(movieId.toString())
        .get();

    return doc.exists;
  }

  @override
  Future<List<Map<String, dynamic>>> getWatchlist({
    required String userId,
  }) async {
    final snapshot = await _watchlistCollection(userId)
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }
}