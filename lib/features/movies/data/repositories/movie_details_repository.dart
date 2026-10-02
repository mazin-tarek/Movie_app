import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie_details_entity.dart';
import '../datasources/movie_details_remote_data_source.dart';

abstract class MovieDetailsRepository {
  Future<Either<Failure, MovieDetailsEntity>> getMovieDetails({
    required int movieId,
  });
}

class MovieDetailsRepositoryImpl implements MovieDetailsRepository {
  final MovieDetailsRemoteDataSource remoteDataSource;

  MovieDetailsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, MovieDetailsEntity>> getMovieDetails({
    required int movieId,
  }) async {
    try {
      final movieDetails = await remoteDataSource.getMovieDetails(
        movieId: movieId,
      );

      return Right(movieDetails);
    } catch (e) {
      return Left(
        NetworkFailure(e.toString()),
      );
    }
  }
}