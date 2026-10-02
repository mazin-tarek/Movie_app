import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/history/data/datasources/history_remote_data_source.dart';

abstract class HistoryRepository {
  Future<void> addToHistory({
    required String userId,
    required MovieEntity movie,
  });

  Future<List<MovieEntity>> getHistory({
    required String userId,
  });
}

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> addToHistory({
    required String userId,
    required MovieEntity movie,
  }) {
    return remoteDataSource.addToHistory(
      userId: userId,
      movie: {
        'id': movie.id,
        'title': movie.title,
        'titleEnglish': movie.titleEnglish,
        'year': movie.year,
        'rating': movie.rating,
        'runtime': movie.runtime,
        'genres': movie.genres,
        'summary': movie.summary,
        'backgroundImage': movie.backgroundImage,
        'mediumCoverImage': movie.mediumCoverImage,
        'largeCoverImage': movie.largeCoverImage,
      },
    );
  }

  @override
  Future<List<MovieEntity>> getHistory({
    required String userId,
  }) async {
    final movies = await remoteDataSource.getHistory(
      userId: userId,
    );

    return movies.map((movie) {
      return MovieEntity(
        id: movie['id'] ?? 0,
        title: movie['title'] ?? '',
        titleEnglish: movie['titleEnglish'] ?? '',
        year: movie['year'] ?? 0,
        rating: (movie['rating'] as num?)?.toDouble() ?? 0,
        runtime: movie['runtime'] ?? 0,
        genres: List<String>.from(movie['genres'] ?? []),
        summary: movie['summary'] ?? '',
        backgroundImage: movie['backgroundImage'] ?? '',
        mediumCoverImage: movie['mediumCoverImage'] ?? '',
        largeCoverImage: movie['largeCoverImage'] ?? '',
      );
    }).toList();
  }
}