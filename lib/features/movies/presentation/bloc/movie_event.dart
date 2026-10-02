import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class GetMoviesRequested extends MovieEvent {
  final int page;
  final String? genre;
  const GetMoviesRequested({this.page = 1, this.genre});
  @override
  List<Object?> get props => [page, genre];
}class GetMoviesByGenreRequested extends MovieEvent {
  final String genre;
  final int page;

  const GetMoviesByGenreRequested({
    required this.genre,
    this.page = 1,
  });

  @override
  List<Object?> get props => [
        genre,
        page,
      ];
}
