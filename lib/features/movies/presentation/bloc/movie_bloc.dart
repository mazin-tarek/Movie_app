import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/movies/domain/usecases/get_movies_use_case.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetMoviesUseCase getMoviesUseCase;

  final Map<String, List<MovieEntity>> _moviesByGenre = {};

  // الصفحات التي يتم تحميلها حاليًا.
  final Set<String> _loadingPages = {};

  // الصفحات التي تم تحميلها بالفعل.
  final Set<String> _loadedPages = {};

  static const List<String> genres = [
    'Action',
    'Comedy',
    'Drama',
  ];

  MovieBloc({
    required this.getMoviesUseCase,
  })  : super(const MovieInitial()) {
  on<GetMoviesRequested>(_onGetMoviesRequested);
  on<GetMoviesByGenreRequested>(_onGetMoviesByGenreRequested);
  on<RefreshMoviesRequested>(_onRefreshMoviesRequested);
}

  Future<void> _onGetMoviesRequested(
    GetMoviesRequested event,
    Emitter<MovieState> emit,
  ) async {
    final key = event.genre ?? 'all';
    final pageKey = '$key-${event.page}';

    // منع نفس الصفحة من التحميل أكثر من مرة.
    if (_loadingPages.contains(pageKey) ||
        _loadedPages.contains(pageKey)) {
      return;
    }

    _loadingPages.add(pageKey);

    final isFirstRequest =
        event.page == 1 && _moviesByGenre[key] == null;

    if (isFirstRequest) {
      emit(const MovieLoading());
    }

    try {
      final result = await getMoviesUseCase(
        page: event.page,
        genre: event.genre,
      );

      result.fold(
        (failure) {
          if (isFirstRequest) {
            emit(
              MovieError(
                message: failure.message,
              ),
            );
          }
        },
        (movies) {
          final existingMovies =
              _moviesByGenre[key] ?? <MovieEntity>[];

          if (event.page == 1) {
            _moviesByGenre[key] = movies;
          } else {
            _moviesByGenre[key] = [
              ...existingMovies,
              ...movies,
            ];
          }

          _loadedPages.add(pageKey);

          emit(
            MovieSuccess(
              moviesByGenre:
                  Map<String, List<MovieEntity>>.from(
                _moviesByGenre,
              ),
              page: event.page,
              lastRequestedGenre: event.genre,
            ),
          );

          // تحميل Genres الـ Home مرة واحدة فقط.
          if (event.genre == null && event.page == 1) {
            for (final genre in genres) {
              add(
                GetMoviesByGenreRequested(
                  genre: genre,
                ),
              );
            }
          }
        },
      );
    } finally {
      _loadingPages.remove(pageKey);
    }
  }

  Future<void> _onGetMoviesByGenreRequested(
    GetMoviesByGenreRequested event,
    Emitter<MovieState> emit,
  ) async {
    final key = event.genre;
    final pageKey = '$key-${event.page}';

    // منع duplicate requests.
    if (_loadingPages.contains(pageKey) ||
        _loadedPages.contains(pageKey)) {
      return;
    }

    _loadingPages.add(pageKey);

    emit(
      MovieGenreLoading(
        previousState: state,
        genre: event.genre,
      ),
    );

    try {
      final result = await getMoviesUseCase(
        genre: event.genre,
        page: event.page,
      );

      result.fold(
        (failure) {
          // نرجع البيانات الموجودة بدل ما نخلي الشاشة في loading.
          emit(
            MovieSuccess(
              moviesByGenre:
                  Map<String, List<MovieEntity>>.from(
                _moviesByGenre,
              ),
              lastRequestedGenre: event.genre,
            ),
          );
        },
        (movies) {
          final existingMovies =
              _moviesByGenre[event.genre] ?? <MovieEntity>[];

          if (event.page == 1) {
            _moviesByGenre[event.genre] = movies;
          } else {
            _moviesByGenre[event.genre] = [
              ...existingMovies,
              ...movies,
            ];
          }

          _loadedPages.add(pageKey);

          emit(
            MovieSuccess(
              moviesByGenre:
                  Map<String, List<MovieEntity>>.from(
                _moviesByGenre,
              ),
              page: event.page,
              lastRequestedGenre: event.genre,
            ),
          );
        },
      );
    } finally {
      _loadingPages.remove(pageKey);
    }
  }
  Future<void> _onRefreshMoviesRequested(
  RefreshMoviesRequested event,
  Emitter<MovieState> emit,
) async {
  // نمسح الـ cache والصفحات المحملة
  _moviesByGenre.clear();
  _loadingPages.clear();
  _loadedPages.clear();

  emit(const MovieLoading());

  final result = await getMoviesUseCase(
    page: 1,
  );

  result.fold(
    (failure) {
      emit(
        MovieError(
          message: failure.message,
        ),
      );
    },
    (movies) {
      _moviesByGenre['all'] = movies;
      _loadedPages.add('all-1');

      emit(
        MovieSuccess(
          moviesByGenre: Map<String, List<MovieEntity>>.from(
            _moviesByGenre,
          ),
          page: 1,
          lastRequestedGenre: null,
        ),
      );

      // إعادة تحميل الـ genres
      for (final genre in genres) {
        add(
          GetMoviesByGenreRequested(
            genre: genre,
          ),
        );
      }
    },
  );
}
  
}
class RefreshMoviesRequested extends MovieEvent {
  const RefreshMoviesRequested();

  @override
  List<Object?> get props => [];
}