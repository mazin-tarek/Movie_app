import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_movie_details_usecase.dart';
import 'movie_details_event.dart';
import 'movie_details_state.dart';

class MovieDetailsBloc
    extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final GetMovieDetailsUseCase getMovieDetailsUseCase;

  MovieDetailsBloc({
    required this.getMovieDetailsUseCase,
  }) : super(const MovieDetailsInitial()) {
    on<GetMovieDetailsRequested>(
      _onGetMovieDetailsRequested,
    );

    on<RetryMovieDetailsRequested>(
      _onRetryMovieDetailsRequested,
    );
  }

  Future<void> _onGetMovieDetailsRequested(
    GetMovieDetailsRequested event,
    Emitter<MovieDetailsState> emit,
  ) {
    return _loadMovieDetails(
      movieId: event.movieId,
      emit: emit,
    );
  }

  Future<void> _onRetryMovieDetailsRequested(
    RetryMovieDetailsRequested event,
    Emitter<MovieDetailsState> emit,
  ) {
    return _loadMovieDetails(
      movieId: event.movieId,
      emit: emit,
    );
  }

  Future<void> _loadMovieDetails({
    required int movieId,
    required Emitter<MovieDetailsState> emit,
  }) async {
    emit(const MovieDetailsLoading());

    final result = await getMovieDetailsUseCase(
      movieId: movieId,
    );

    result.fold(
      (failure) {
        emit(
          MovieDetailsError(
            message: failure.message,
          ),
        );
      },
      (movie) {
        emit(
          MovieDetailsSuccess(
            movie: movie,
          ),
        );
      },
    );
  }
}