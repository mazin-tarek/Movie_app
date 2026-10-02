import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/watchlist/data/repositories/watchlist_repository.dart';

class AddToWatchlist {
  final WatchlistRepository repository;

  AddToWatchlist({
    required this.repository,
  });

  Future<void> call({
    required String userId,
    required MovieEntity movie,
  }) {
    return repository.addToWatchlist(
      userId: userId,
      movie: movie,
    );
  }
}