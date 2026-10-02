import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';

class FeaturedMovieCarousel extends StatefulWidget {
  final List<MovieEntity> movies;
  final ValueChanged<MovieEntity>? onMovieChanged;

  const FeaturedMovieCarousel({
    super.key,
    required this.movies,
    this.onMovieChanged,
  });

  @override
  State<FeaturedMovieCarousel> createState() => _FeaturedMovieCarouselState();
}

class _FeaturedMovieCarouselState extends State<FeaturedMovieCarousel> {
  late final PageController _pageController;

  double _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.62);

    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page ?? 0;

    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = page;
    });

    final index = page.round();

    if (index >= 0 && index < widget.movies.length) {
      widget.onMovieChanged?.call(widget.movies[index]);
    }
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onPageChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 390,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.movies.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final movie = widget.movies[index];

          final difference = (_currentPage - index).abs();

          final scale = (1 - (difference * 0.20)).clamp(0.80, 1.0);

          return Center(
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: _FeaturedMovieCard(movie: movie),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  final MovieEntity movie;

  const _FeaturedMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<MovieDetailsBloc>()
            ..add(
              GetMovieDetailsRequested(
                movieId: movie.id,
              ),
            ),
          child: MovieDetailsScreen(
            movie: movie,
          ),
        ),
      ),
    );
  },
      child: AspectRatio(
        aspectRatio: 0.68,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                movie.largeCoverImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF242424),
                    child: const Center(
                      child: Icon(
                        Icons.movie_outlined,
                        color: Colors.white38,
                        size: 45,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
      
                  return const MovieSkeletonBox(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  );
                },
              ),
            ),
      
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(AppAssets.rate, width: 16, height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
