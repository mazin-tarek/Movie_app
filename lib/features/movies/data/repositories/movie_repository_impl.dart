import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/movies/data/repositories/movie_repository.dart';
import '../../domain/entities/movie_entity.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MovieEntity>>> getMovies({
    int page = 1,
    String? genre,
  }) async {
    try {
      final response = await remoteDataSource.getMovies(
        page: page,
        genre: genre,
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(
          NetworkFailure(
            'Request timed out. Please try again.',
          ),
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return const Left(
          NetworkFailure(
            'No internet connection.',
          ),
        );
      }

      return const Left(
        ServerFailure(
          'Something went wrong. Please try again.',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          e.toString(),
        ),
      );
    }
  }
}