import 'package:movieapp/features/watchlist/data/repositories/watchlist_repository.dart';

class RemoveFromWatchlist {
  final WatchlistRepository repository;

  RemoveFromWatchlist({
    required this.repository,
  });

  Future<void> call({
    required String userId,
    required int movieId,
  }) {
    return repository.removeFromWatchlist(
      userId: userId,
      movieId: movieId,
    );
  }
}