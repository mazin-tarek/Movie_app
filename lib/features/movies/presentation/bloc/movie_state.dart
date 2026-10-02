import 'package:equatable/equatable.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

class MovieState extends Equatable{
  const MovieState();
  @override
  List<Object?> get props =>[];

}

class MovieInitial extends MovieState{
  const MovieInitial();
}
class MovieLoading extends MovieState{
  const MovieLoading();
}
class MovieGenreLoading extends MovieState {
  final MovieState previousState;
  final String genre;

  const MovieGenreLoading({
    required this.previousState,
    required this.genre,
  });

  @override
  List<Object?> get props => [
        previousState,
        genre,
      ];
}class MovieSuccess extends MovieState {
  final Map<String, List<MovieEntity>> moviesByGenre;
  final int page;
  final String? lastRequestedGenre;

  const MovieSuccess({
    required this.moviesByGenre,
    this.page = 1,
    this.lastRequestedGenre,
  });

  @override
  List<Object?> get props => [
        moviesByGenre,
        page,
        lastRequestedGenre,
      ];
}
class MovieError extends MovieState{
  final String message;
  const MovieError({required this.message});
  @override
  List<Object?> get props => [message];

} 