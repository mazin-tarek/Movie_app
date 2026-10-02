import 'package:movieapp/features/history/data/repositories/history_repository.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

class AddToHistory {
  final HistoryRepository repository;

  AddToHistory({
    required this.repository,
  });

  Future<void> call({
    required String userId,
    required MovieEntity movie,
  }) {
    return repository.addToHistory(
      userId: userId,
      movie: movie,
    );
  }
}