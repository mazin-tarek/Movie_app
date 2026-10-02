import 'package:equatable/equatable.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class AddMovieToWatchlist extends WatchlistEvent {
  final String userId;
  final MovieEntity movie;

  const AddMovieToWatchlist({
    required this.userId,
    required this.movie,
  });

  @override
  List<Object?> get props => [userId, movie];
}

class RemoveMovieFromWatchlist extends WatchlistEvent {
  final String userId;
  final int movieId;

  const RemoveMovieFromWatchlist({
    required this.userId,
    required this.movieId,
  });

  @override
  List<Object?> get props => [userId, movieId];
}

class CheckMovieInWatchlist extends WatchlistEvent {
  final String userId;
  final int movieId;

  const CheckMovieInWatchlist({
    required this.userId,
    required this.movieId,
  });

  @override
  List<Object?> get props => [userId, movieId];
}

class GetWatchlistRequested extends WatchlistEvent {
  final String userId;

  const GetWatchlistRequested({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}