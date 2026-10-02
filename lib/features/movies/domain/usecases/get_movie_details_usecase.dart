import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie_details_entity.dart';
import '../../data/repositories/movie_details_repository.dart';

class GetMovieDetailsUseCase {
  final MovieDetailsRepository repository;

  GetMovieDetailsUseCase({
    required this.repository,
  });

  Future<Either<Failure, MovieDetailsEntity>> call({
    required int movieId,
  }) {
    return repository.getMovieDetails(
      movieId: movieId,
    );
  }
}