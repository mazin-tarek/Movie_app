import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/search_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/search_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/search_state.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  void _search(String value) {
    final query = value.trim();

    _debounce?.cancel();

    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });

    if (query.isEmpty) {
      context.read<SearchBloc>().add(
            const SearchMoviesRequested(
              query: '',
              page: 1,
            ),
          );
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        context.read<SearchBloc>().add(
              SearchMoviesRequested(
                query: query,
                page: 1,
              ),
            );
      },
    );
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    final state = context.read<SearchBloc>().state;

    if (state is! SearchSuccess) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    context.read<SearchBloc>().add(
          SearchMoviesRequested(
            query: query,
            page: _currentPage,
          ),
        );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: l10n.searchMovies,
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SvgPicture.asset(
                      AppAssets.searchTab,
                      width: 16,
                      height: 16,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocListener<SearchBloc, SearchState>(
                listener: (context, state) {
                  if (state is SearchSuccess || state is SearchError) {
                    if (_isLoadingMore) {
                      setState(() {
                        _isLoadingMore = false;
                        if (state is SearchSuccess) {
                          _currentPage = state.page;
                        }
                      });
                    }
                  }
                },
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return Center(
                        child: Text(
                          l10n.searchForMovie,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (state is SearchLoading) {
                      return const MovieGridSkeleton();
                    }

                    if (state is SearchError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is SearchSuccess) {
                      if (state.movies.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noMoviesFound,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: state.movies.length,
                        itemBuilder: (context, index) {
                          return _SearchMovieCard(
                            movie: state.movies[index],
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMovieCard extends StatelessWidget {
  final MovieEntity movie;

  const _SearchMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<MovieDetailsBloc>()
                ..add(GetMovieDetailsRequested(movieId: movie.id)),
              child: MovieDetailsScreen(movie: movie),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: movie.mediumCoverImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    placeholder: (context, url) {
                      return const MovieSkeletonBox(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: const Color(0xFF282A28),
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          AppAssets.rate,
                          width: 15,
                          height: 15,
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
        ],
      ),
    );
  }
}
