import 'package:movieapp/features/watchlist/data/repositories/watchlist_repository.dart';

class IsMovieInWatchlist {
  final WatchlistRepository repository;

  IsMovieInWatchlist({
    required this.repository,
  });

  Future<bool> call({
    required String userId,
    required int movieId,
  }) {
    return repository.isInWatchlist(
      userId: userId,
      movieId: movieId,
    );
  }
}