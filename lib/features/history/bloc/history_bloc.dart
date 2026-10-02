import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/features/history/domain/usecases/add_to_history.dart';
import 'package:movieapp/features/history/domain/usecases/get_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final AddToHistory addToHistory;
  final GetHistory getHistory;

  HistoryBloc({
    required this.addToHistory,
    required this.getHistory,
  }) : super(HistoryInitial()) {
    on<AddMovieToHistory>(_addMovieToHistory);
    on<GetHistoryRequested>(_getHistory);
  }

  Future<void> _addMovieToHistory(
    AddMovieToHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await addToHistory(
        userId: event.userId,
        movie: event.movie,
      );
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _getHistory(
    GetHistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    try {
      final movies = await getHistory(
        userId: event.userId,
      );

      emit(HistoryLoaded(movies));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}