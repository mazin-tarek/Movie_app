import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

import '../../domain/usecases/search_movies_use_case.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchMoviesUseCase searchMoviesUseCase;

  final List<MovieEntity> _movies = [];

  SearchBloc({
    required this.searchMoviesUseCase,
  }) : super(SearchInitial()) {
    on<SearchMoviesRequested>(_onSearchMoviesRequested);
  }

  Future<void> _onSearchMoviesRequested(
    SearchMoviesRequested event,
    Emitter<SearchState> emit,
  ) async {
    final isFirstPage = event.page == 1;

    if (isFirstPage) {
      emit(SearchLoading());
      _movies.clear();
    }

    final result = await searchMoviesUseCase(
      query: event.query,
      page: event.page,
    );

    result.fold(
      (failure) {
        if (isFirstPage) {
          emit(
            SearchError(
              message: failure.message,
            ),
          );
        } else {
          // Keep the already loaded results visible and reset the UI's
          // pagination cursor so the same page can be retried.
          emit(
            SearchSuccess(
              movies: List.from(_movies),
              page: event.page - 1,
              query: event.query,
            ),
          );
        }
      },
      (movies) {
        _movies.addAll(movies);

        emit(
          SearchSuccess(
            movies: List.from(_movies),
            page: event.page,
            query: event.query,
          ),
        );
      },
    );
  }
} 