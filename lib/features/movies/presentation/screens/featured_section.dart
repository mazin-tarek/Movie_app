import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieapp/core/widgets/featured_movie_carousel.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

class FeaturedSection extends StatefulWidget {
  final List<MovieEntity> movies;

  const FeaturedSection({super.key, required this.movies});

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection> {
  MovieEntity? _selectedMovie;

  @override
  void initState() {
    super.initState();
    _updateSelectedMovie();
  }

  @override
  void didUpdateWidget(covariant FeaturedSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.movies != widget.movies) {
      _updateSelectedMovie();
    }
  }

  void _updateSelectedMovie() {
    if (widget.movies.isEmpty) {
      _selectedMovie = null;
      return;
    }

    final selectedMovieExists =
        _selectedMovie != null &&
        widget.movies.any((movie) => movie.id == _selectedMovie!.id);

    if (!selectedMovieExists) {
      _selectedMovie = widget.movies.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty || _selectedMovie == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;

    final featuredHeight = screenWidth < 380 ? 520.0 : 550.0;

    return SizedBox(
      width: double.infinity,
      height: featuredHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,

        fit: StackFit.expand,
        children: [
          // =========================================================
          // BACKGROUND POSTER
          // =========================================================
          Positioned.fill(
            child: Image.network(
              _selectedMovie!.largeCoverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF0E0E0E));
              },
            ),
          ),

          // =========================================================
          // DARK OVERLAY
          // =========================================================
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.65, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.45),
                    const Color(0xFF0E0E0E),
                  ],
                ),
              ),
            ),
          ),

          // =========================================================
          // CONTENT
          // =========================================================
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // -------------------------
                // Available Now
                // -------------------------
                Text(
                  'Available Now',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.caveatBrush(
                    color: Colors.white,
                    fontSize: screenWidth < 380 ? 55 : 55,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 5),

                // -------------------------
                // Movie Carousel
                // -------------------------
                Expanded(
                  child: FeaturedMovieCarousel(
                    movies: widget.movies,
                    onMovieChanged: (movie) {
                      if (_selectedMovie?.id == movie.id) {
                        return;
                      }

                      setState(() {
                        _selectedMovie = movie;
                      });
                    },
                  ),
                ),

                // -------------------------
                // Watch Now
                // -------------------------
                Text(
                  'Watch Now',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.caveatBrush(
                    color: Colors.white,
                    fontSize: screenWidth < 380 ? 55 : 55,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
