import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';

class MovieCard extends StatelessWidget {
  final MovieEntity movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 0.68,
              child: _MovieImage(movie: movie),
            ),
          ),

          const SizedBox(height: 8),

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

          const SizedBox(height: 4),

          Row(
            children: [
              SvgPicture.asset(
                AppAssets.rate,
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 4),
              Text(
                movie.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                movie.year.toString(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _MovieImage extends StatelessWidget {
  final MovieEntity movie;

  const _MovieImage({
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final mediumUrl = movie.mediumCoverImage.trim();
    final largeUrl = movie.largeCoverImage.trim();

    if (mediumUrl.isEmpty && largeUrl.isEmpty) {
      return const _MovieImageError();
    }

    final primaryUrl = mediumUrl.isNotEmpty ? mediumUrl : largeUrl;

    return CachedNetworkImage(
      imageUrl: primaryUrl,
      fit: BoxFit.cover,
      memCacheWidth: 250,
      maxWidthDiskCache: 250,
      fadeInDuration: const Duration(milliseconds: 200),

      placeholder: (_, __) {
        return const _MovieImagePlaceholder();
      },

      errorWidget: (_, __, ___) {
        if (largeUrl.isNotEmpty && largeUrl != primaryUrl) {
          return CachedNetworkImage(
            imageUrl: largeUrl,
            fit: BoxFit.cover,
            memCacheWidth: 250,
            maxWidthDiskCache: 250,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, __) {
              return const _MovieImagePlaceholder();
            },
            errorWidget: (_, __, ___) {
              return const _MovieImageError();
            },
          );
        }

        return const _MovieImageError();
      },
    );
  }
}

class _MovieImagePlaceholder extends StatelessWidget {
  const _MovieImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF242424),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white38,
        ),
      ),
    );
  }
}

class _MovieImageError extends StatelessWidget {
  const _MovieImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF242424),
      alignment: Alignment.center,
      child: const Icon(
        Icons.movie_outlined,
        color: Colors.white54,
        size: 35,
      ),
    );
  }
}