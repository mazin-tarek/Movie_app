import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movieapp/features/watchlist/domain/usecases/add_to_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/is_movie_in_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/remove_from_watchlist.dart';

import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final AddToWatchlist addToWatchlist;
  final RemoveFromWatchlist removeFromWatchlist;
  final IsMovieInWatchlist isMovieInWatchlist;
  final GetWatchlist getWatchlist;

  WatchlistBloc({
    required this.addToWatchlist,
    required this.removeFromWatchlist,
    required this.isMovieInWatchlist,
    required this.getWatchlist,
  }) : super(WatchlistInitial()) {
    on<AddMovieToWatchlist>(_onAddMovie);
    on<RemoveMovieFromWatchlist>(_onRemoveMovie);
    on<CheckMovieInWatchlist>(_onCheckMovie);
    on<GetWatchlistRequested>(_onGetWatchlist);
  }

  Future<void> _onAddMovie(
    AddMovieToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(
      const WatchlistActionLoading(
        isInWatchlist: false,
      ),
    );

    try {
      await addToWatchlist(
        userId: event.userId,
        movie: event.movie,
      );

      emit(
        const WatchlistMovieStatusLoaded(
          isInWatchlist: true,
        ),
      );
    } catch (e) {
      emit(
        WatchlistError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRemoveMovie(
    RemoveMovieFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(
      const WatchlistActionLoading(
        isInWatchlist: true,
      ),
    );

    try {
      await removeFromWatchlist(
        userId: event.userId,
        movieId: event.movieId,
      );

      emit(
        const WatchlistMovieStatusLoaded(
          isInWatchlist: false,
        ),
      );
    } catch (e) {
      emit(
        WatchlistError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCheckMovie(
    CheckMovieInWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final isInWatchlist = await isMovieInWatchlist(
        userId: event.userId,
        movieId: event.movieId,
      );

      emit(
        WatchlistMovieStatusLoaded(
          isInWatchlist: isInWatchlist,
        ),
      );
    } catch (e) {
      emit(
        WatchlistError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onGetWatchlist(
    GetWatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());

    try {
      final movies = await getWatchlist(
        userId: event.userId,
      );

      emit(
        WatchlistLoaded(
          movies: movies,
        ),
      );
    } catch (e) {
      emit(
        WatchlistError(
          message: e.toString(),
        ),
      );
    }
  }
}