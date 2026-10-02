import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../datasources/search_remote_data_source.dart';
import '../../domain/entities/movie_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<MovieEntity>>> searchMovies({
    required String query,
    int page = 1,
  });
}

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.searchMovies(
        query: query,
        page: page,
      );

      if (response.status != 'ok') {
        return Left(
          ServerFailure(
            response.statusMessage ?? 'Something went wrong',
          ),
        );
      }

      final movies = response.data?.movies ?? [];

      return Right(
        movies.map((movie) {
          return MovieEntity(
            id: movie.id ?? 0,
            title: movie.title ?? '',
            titleEnglish: movie.titleEnglish ?? '',
            year: movie.year ?? 0,
            rating: movie.rating ?? 0,
            runtime: movie.runtime ?? 0,
            genres: movie.genres ?? [],
            summary: movie.summary ?? '',
            backgroundImage: movie.backgroundImage ?? '',
            mediumCoverImage: movie.mediumCoverImage ?? '',
            largeCoverImage: movie.largeCoverImage ?? '',
          );
        }).toList(),
      );
    } catch (e) {
      return Left(
        NetworkFailure(e.toString()),
      );
    }
  }
}