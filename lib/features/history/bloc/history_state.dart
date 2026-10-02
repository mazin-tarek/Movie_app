import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<MovieEntity> movies;

  const HistoryLoaded(this.movies);
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);
}