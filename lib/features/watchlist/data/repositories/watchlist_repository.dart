import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/watchlist/data/datasources/watchlist_remote_data_source.dart';

abstract class WatchlistRepository {
  Future<void> addToWatchlist({
    required String userId,
    required MovieEntity movie,
  });

  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  });

  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  });

  Future<List<MovieEntity>> getWatchlist({
    required String userId,
  });
}

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistRemoteDataSource remoteDataSource;

  WatchlistRepositoryImpl({
    required this.remoteDataSource,
  });

  Map<String, dynamic> _movieToMap(MovieEntity movie) {
    return {
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
    };
  }

  MovieEntity _movieFromMap(Map<String, dynamic> json) {
    return MovieEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      titleEnglish: json['titleEnglish'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt() ?? 0,
      genres: (json['genres'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
      backgroundImage: json['backgroundImage'] as String? ?? '',
      mediumCoverImage: json['mediumCoverImage'] as String? ?? '',
      largeCoverImage: json['largeCoverImage'] as String? ?? '',
    );
  }

  @override
  Future<void> addToWatchlist({
    required String userId,
    required MovieEntity movie,
  }) async {
    try {
      await remoteDataSource.addToWatchlist(
        userId: userId,
        movie: _movieToMap(movie),
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  }) async {
    try {
      await remoteDataSource.removeFromWatchlist(
        userId: userId,
        movieId: movieId,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  }) async {
    try {
      return await remoteDataSource.isInWatchlist(
        userId: userId,
        movieId: movieId,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<MovieEntity>> getWatchlist({
    required String userId,
  }) async {
    try {
      final movies = await remoteDataSource.getWatchlist(
        userId: userId,
      );

      return movies.map(_movieFromMap).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}