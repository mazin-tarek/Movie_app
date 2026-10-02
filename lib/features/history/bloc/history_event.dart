import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class AddMovieToHistory extends HistoryEvent {
  final String userId;
  final MovieEntity movie;

  const AddMovieToHistory({
    required this.userId,
    required this.movie,
  });
}

class GetHistoryRequested extends HistoryEvent {
  final String userId;

  const GetHistoryRequested({
    required this.userId,
  });
}