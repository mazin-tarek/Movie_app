import 'package:movieapp/features/history/data/repositories/history_repository.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

class GetHistory {
  final HistoryRepository repository;

  GetHistory({
    required this.repository,
  });

  Future<List<MovieEntity>> call({
    required String userId,
  }) {
    return repository.getHistory(userId: userId);
  }
}