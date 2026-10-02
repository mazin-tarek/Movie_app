import 'package:dartz/dartz.dart';
import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/movies/data/repositories/movie_repository.dart';
import '../entities/movie_entity.dart';

class GetMoviesUseCase {
  final MovieRepository repository;

  GetMoviesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<MovieEntity>>> call({
    int page = 1,
    String? genre,
  }) {
    return repository.getMovies(
      page: page,
      genre: genre,
    );
  }
}