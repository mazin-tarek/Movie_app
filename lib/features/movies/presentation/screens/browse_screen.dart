import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_state.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  static const List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  final ScrollController _scrollController = ScrollController();

  String _selectedGenre = 'Action';
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  void _selectGenre(String genre) {
    if (_selectedGenre == genre) return;

    setState(() {
      _selectedGenre = genre;
      _currentPage = 1;
      _isLoadingMore = false;
    });

    context.read<MovieBloc>().add(
      GetMoviesByGenreRequested(genre: genre, page: 1),
    );
  }

  void _loadNextPage() {
    if (_isLoadingMore) return;

    final state = context.read<MovieBloc>().state;

    if (state is! MovieSuccess) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    context.read<MovieBloc>().add(
      GetMoviesByGenreRequested(genre: _selectedGenre, page: _currentPage),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: ColoredBox(
        color: AppColors.darkBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: genres.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = genre == _selectedGenre;

                    return GestureDetector(
                      onTap: () => _selectGenre(genre),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryButton
                              : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.primaryButton,
                                  width: 2,
                                ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Movies
              Expanded(
                child: BlocBuilder<MovieBloc, MovieState>(
                  builder: (context, state) {
                    if (state is MovieLoading) {
                      return const MovieGridSkeleton();
                    }

                    if (state is MovieGenreLoading) {
                      final previousState = state.previousState;

                      if (previousState is MovieSuccess &&
                          previousState
                                  .moviesByGenre[_selectedGenre]
                                  ?.isNotEmpty ==
                              true) {
                        return _buildMovies(previousState, l10n);
                      }

                      return const MovieGridSkeleton();
                    }

                    if (state is MovieSuccess) {
                      if (_isLoadingMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isLoadingMore = false;
                            });
                          }
                        });
                      }

                      return _buildMovies(state, l10n);
                    }

                    if (state is MovieError) {
                      _isLoadingMore = false;

                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovies(MovieSuccess state, AppLocalizations l10n) {
    final movies = state.moviesByGenre[_selectedGenre] ?? [];

    if (movies.isEmpty) {
      return Center(
        child: Text(l10n.noMoviesFound, style: const TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      physics: const BouncingScrollPhysics(),
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

        return _BrowseMovieCard(
          movie: movie,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) =>
                      sl<MovieDetailsBloc>()
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

class _BrowseMovieCard extends StatelessWidget {
  final dynamic movie;
  final VoidCallback onTap;

  const _BrowseMovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      movie.mediumCoverImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: const Color(0xFF242424),
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Rating
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssets.rate,
                            width: 13,
                            height: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 7),

            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              movie.year.toString(),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
