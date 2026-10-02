import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_state.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class GenreScreen extends StatefulWidget {
  final String genre;

  const GenreScreen({
    super.key,
    required this.genre,
  });

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late final MovieBloc _movieBloc;

  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _movieBloc = sl<MovieBloc>()
      ..add(
        GetMoviesByGenreRequested(
          genre: widget.genre,
        ),
      );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    _movieBloc.add(
      GetMoviesByGenreRequested(
        genre: widget.genre,
        page: _currentPage,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _movieBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider.value(
      value: _movieBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E0E0E),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.genre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return const MovieGridSkeleton();
            }

            if (state is MovieGenreLoading) {
              final previousState = state.previousState;

              if (previousState is MovieSuccess &&
                  (previousState.moviesByGenre[widget.genre]?.isNotEmpty ??
                      false)) {
                return _buildMovies(previousState);
              }

              return const MovieGridSkeleton();
            }

            if (state is MovieSuccess) {
                _isLoadingMore = false;

              return _buildMovies(state);
            }

            if (state is MovieError) {
              _isLoadingMore = false;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMovies(MovieSuccess state) {
    final l10n = AppLocalizations.of(context)!;
    final movies = state.moviesByGenre[widget.genre] ?? [];

    if (movies.isEmpty) {
      return Center(
        child: Text(
          l10n.noMoviesFound,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: movies.length + (_isLoadingMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        if (index == movies.length) {
          return const MovieGridSkeletonCard();
        }

        final movie = movies[index];

        return _MovieGridCard(
          imageUrl: movie.mediumCoverImage,
          title: movie.title,
          rating: movie.rating,
          year: movie.year,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<MovieDetailsBloc>()
                    ..add(GetMovieDetailsRequested(movieId: movie.id)),
                  child: MovieDetailsScreen(movie: movie),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MovieGridCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final int year;
  final VoidCallback? onTap;

  const _MovieGridCard({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.year,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    placeholder: (context, url) {
                      return const MovieSkeletonBox(
                        borderRadius: BorderRadius.all(
                          Radius.circular(14),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: const Color(0xFF242424),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.movie_outlined,
                          color: Colors.white38,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.rate, width: 15, height: 15),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    year.toString(),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
