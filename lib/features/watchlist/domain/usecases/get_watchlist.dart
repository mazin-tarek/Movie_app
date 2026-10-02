import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/watchlist/data/repositories/watchlist_repository.dart';

class GetWatchlist {
  final WatchlistRepository repository;

  GetWatchlist({
    required this.repository,
  });

  Future<List<MovieEntity>> call({
    required String userId,
  }) {
    return repository.getWatchlist(
      userId: userId,
    );
  }
}