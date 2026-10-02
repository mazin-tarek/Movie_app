import 'package:equatable/equatable.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetMovieDetailsRequested extends MovieDetailsEvent {
  final int movieId;

  const GetMovieDetailsRequested({
    required this.movieId,
  });

  @override
  List<Object?> get props => [movieId];
}
class RetryMovieDetailsRequested extends MovieDetailsEvent {
  final int movieId;

  const RetryMovieDetailsRequested({
    required this.movieId,
  });

  @override
  List<Object?> get props => [movieId];
}