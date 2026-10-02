import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/widgets/movie_section.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_state.dart';
import 'package:movieapp/features/movies/presentation/screens/featured_section.dart';
import 'package:movieapp/features/movies/presentation/screens/genre_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static const String routeName = '/home';
}

class _HomeScreenState extends State<HomeScreen> {
  late final MovieBloc _movieBloc;

  @override
  void initState() {
    super.initState();

    _movieBloc = sl<MovieBloc>()..add(const GetMoviesRequested());
  }

  @override
  void dispose() {
    _movieBloc.close();
    super.dispose();
  }

  MovieSuccess? _getSuccessState(MovieState state) {
    if (state is MovieSuccess) {
      return state;
    }

    if (state is MovieGenreLoading && state.previousState is MovieSuccess) {
      return state.previousState as MovieSuccess;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _movieBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E0E),
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    MovieSkeletonBox(
                      height: 550,
                      borderRadius: BorderRadius.zero,
                    ),
                    SizedBox(height: 24),
                    MovieRowSkeleton(),
                    SizedBox(height: 24),
                    MovieRowSkeleton(),
                    SizedBox(height: 24),
                    MovieRowSkeleton(),
                  ],
                ),
              );
            }

           if (state is MovieError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white54,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<MovieBloc>().add(
  const RefreshMoviesRequested(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

            final successState = _getSuccessState(state);

            if (successState != null) {
              final movies = successState.moviesByGenre['all'] ?? [];

              final actionMovies = successState.moviesByGenre['Action'] ?? [];

              final comedyMovies = successState.moviesByGenre['Comedy'] ?? [];

              final dramaMovies = successState.moviesByGenre['Drama'] ?? [];

              final isActionLoading =
                  state is MovieGenreLoading && state.genre == 'Action';

              final isComedyLoading =
                  state is MovieGenreLoading && state.genre == 'Comedy';

              final isDramaLoading =
                  state is MovieGenreLoading && state.genre == 'Drama';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    FeaturedSection(movies: movies),

                    if (isActionLoading && actionMovies.isEmpty)
                      const _GenreLoading()
                    else if (actionMovies.isNotEmpty)
                      MovieSection(
                        title: 'Action',
                        movies: actionMovies,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const GenreScreen(genre: 'Action'),
                            ),
                          );
                        },
                      ),

                    if (isComedyLoading && comedyMovies.isEmpty)
                      const _GenreLoading()
                    else if (comedyMovies.isNotEmpty)
                      MovieSection(
                        title: 'Comedy',
                        movies: comedyMovies,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const GenreScreen(genre: 'Comedy'),
                            ),
                          );
                        },
                      ),

                    if (isDramaLoading && dramaMovies.isEmpty)
                      const _GenreLoading()
                    else if (dramaMovies.isNotEmpty)
                      MovieSection(
                        title: 'Drama',
                        movies: dramaMovies,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GenreScreen(genre: 'Drama'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _GenreLoading extends StatelessWidget {
  const _GenreLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: MovieRowSkeleton(),
    );
  }
}
