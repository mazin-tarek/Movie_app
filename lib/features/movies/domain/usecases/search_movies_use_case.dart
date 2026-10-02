import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie_entity.dart';
import '../../data/repositories/search_repository.dart';

class SearchMoviesUseCase {
  final SearchRepository repository;

  SearchMoviesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<MovieEntity>>> call({
    required String query,
    int page = 1,
  }) {
    return repository.searchMovies(
      query: query,
      page: page,
    );
  }
}