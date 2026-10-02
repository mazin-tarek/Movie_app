import 'package:equatable/equatable.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<MovieEntity> movies;

  const WatchlistLoaded({
    required this.movies,
  });

  @override
  List<Object?> get props => [movies];
}

class WatchlistMovieStatusLoaded extends WatchlistState {
  final bool isInWatchlist;

  const WatchlistMovieStatusLoaded({
    required this.isInWatchlist,
  });

  @override
  List<Object?> get props => [isInWatchlist];
}

class WatchlistActionLoading extends WatchlistState {
  final bool isInWatchlist;

  const WatchlistActionLoading({
    required this.isInWatchlist,
  });

  @override
  List<Object?> get props => [isInWatchlist];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}