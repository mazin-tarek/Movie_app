import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<MovieEntity> movies;
  final VoidCallback? onSeeMore;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeMore,
                child: const Text(
                  'See More →',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 14);
              },
              itemBuilder: (context, index) {
                return _MovieSectionCard(movie: movies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _MovieSectionCard extends StatelessWidget {
  final MovieEntity movie;

  const _MovieSectionCard({
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: GestureDetector(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: movie.mediumCoverImage,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  // الكارد عرضه 135، فمش محتاجين صورة ضخمة في الذاكرة.
                  memCacheWidth: 270,

                  placeholder: (_, __) {
                    return const MovieSkeletonBox(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    );
                  },

                  errorWidget: (_, __, ___) {
                    return Container(
                      color: const Color(0xFF242424),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_outlined,
                        color: Colors.white38,
                        size: 35,
                      ),
                    );
                  },
                ),
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

            const SizedBox(height: 4),

            Row(
              children: [
                SvgPicture.asset(
                  AppAssets.rate,
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 3),
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
      ),
    );
  }
}