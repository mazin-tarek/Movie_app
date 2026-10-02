import 'package:dartz/dartz.dart';
import 'package:movieapp/core/errors/failures.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

abstract class MovieRepository {

Future<Either<Failure, List<MovieEntity>>> getMovies({
  int page = 1,
  String? genre,
});}