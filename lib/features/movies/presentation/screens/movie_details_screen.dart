import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';

import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/movies/domain/entities/movie_details_entity.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_state.dart';
import 'package:movieapp/features/movies/presentation/screens/trailer_player_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_event.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_state.dart';
import 'package:movieapp/features/history/bloc/history_bloc.dart';
import 'package:movieapp/features/history/bloc/history_event.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieEntity movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<WatchlistBloc>();
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              bloc.add(
                CheckMovieInWatchlist(
                  userId: user.uid,
                  movieId: movie.id,
                ),
              );
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = sl<HistoryBloc>();
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              bloc.add(
                AddMovieToHistory(
                  userId: user.uid,
                  movie: movie,
                ),
              );
            }
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoading) {
            return const Scaffold(
              backgroundColor: AppColors.darkBackground,
              body: MovieDetailsSkeleton(),
            );
          }

         if (state is MovieDetailsError) {
  return Scaffold(
    backgroundColor: AppColors.darkBackground,
    appBar: AppBar(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white54,
              size: 52,
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

            ElevatedButton.icon(
              onPressed: () {
                context.read<MovieDetailsBloc>().add(
                  RetryMovieDetailsRequested(
                    movieId: movie.id,
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

          if (state is MovieDetailsSuccess) {
            return _MovieDetailsContent(
              movie: state.movie,
              originalMovie: movie,
            );
          }

          return const Scaffold(backgroundColor: AppColors.darkBackground,);
        },
      ),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  final MovieDetailsEntity movie;
  final MovieEntity originalMovie;

  const _MovieDetailsContent({
    required this.movie,
    required this.originalMovie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Hero(movie: movie, originalMovie: originalMovie),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 26),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WatchButton(
                    onPressed: () {
                      if (movie.trailerCode.isEmpty) {
                        debugPrint('TRAILER CODE: ${movie.trailerCode}');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.trailerNotAvailable),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TrailerPlayerScreen(
                            trailerCode: movie.trailerCode,
                            title: movie.title,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _Stats(movie: movie),
                  if (movie.screenshots.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SectionTitle(l10n.screenshots),
                    const SizedBox(height: 9),
                    _Screenshots(screenshots: movie.screenshots),
                  ],
                  const SizedBox(height: 22),
                  _SectionTitle(l10n.summary),
                  const SizedBox(height: 10),
                  Text(
                    movie.descriptionFull.isNotEmpty
                        ? movie.descriptionFull
                        : movie.descriptionIntro,
                    style: const TextStyle(
                      color: Color(0xFFD1D1D1),
                      fontSize: 13,
                      height: 1.42,
                    ),
                  ),
                  if (movie.cast.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(l10n.cast),
                    const SizedBox(height: 9),
                    _CastList(cast: movie.cast),
                  ],
                  if (movie.genres.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(l10n.genres),
                    const SizedBox(height: 9),
                    _Genres(genres: movie.genres),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final MovieDetailsEntity movie;
  final MovieEntity originalMovie;

  const _Hero({required this.movie, required this.originalMovie});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroHeight = MediaQuery.sizeOf(context).width * 1.47;
    final imageUrl = movie.largeCoverImage.isNotEmpty
        ? movie.largeCoverImage
        : movie.backgroundImage;

    return SizedBox(
      height: heroHeight.clamp(430.0, 540.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  memCacheWidth: 900,
  placeholder: (context, url) {
    return const ColoredBox(
      color: AppColors.darkBackground,
    );
  },
  errorWidget: (context, url, error) {
    if (movie.backgroundImage.isNotEmpty &&
        movie.backgroundImage != imageUrl) {
      return CachedNetworkImage(
        imageUrl: movie.backgroundImage,
        fit: BoxFit.cover,
        memCacheWidth: 900,
        errorWidget: (_, _, _) {
          return const ColoredBox(
            color: AppColors.darkBackground,
          );
        },
      );
    }

    return const ColoredBox(
      color: AppColors.darkBackground,
    );
  },
),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x42000000),
                  Color(0x08000000),
                  Color(0xD90E0E0E),
                  AppColors.darkBackground,
                ],
                stops: [0, 0.38, 0.82, 1],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            left: 6,
            right: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _WatchlistButton(movie: originalMovie),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (movie.trailerCode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.trailerNotAvailable)),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrailerPlayerScreen(
                    trailerCode: movie.trailerCode,
                    title: movie.title,
                  ),
                ),
              );
            },

            child: Center(
              child: Container(
                width: 69,
                height: 69,
                decoration: BoxDecoration(
                  color: AppColors.primaryButton,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0x55000000), blurRadius: 12),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 43,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 13,
            child: Column(
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  movie.year.toString(),
                  style: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistButton extends StatelessWidget {
  final MovieEntity movie;

  const _WatchlistButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        var isSaved = false;
        var isLoading = false;

        if (state is WatchlistMovieStatusLoaded) {
          isSaved = state.isInWatchlist;
        }

        if (state is WatchlistActionLoading) {
          isSaved = state.isInWatchlist;
          isLoading = true;
        }

        return IconButton(
          onPressed: isLoading
              ? null
              : () {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    context.push('/login');
                    return;
                  }

                  if (isSaved) {
                    context.read<WatchlistBloc>().add(
                      RemoveMovieFromWatchlist(
                        userId: user.uid,
                        movieId: movie.id,
                      ),
                    );
                  } else {
                    context.read<WatchlistBloc>().add(
                      AddMovieToWatchlist(userId: user.uid, movie: movie),
                    );
                  }
                },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 38, height: 38),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey(isSaved),
              color: isSaved ? AppColors.primaryButton : Colors.white,
              size: 25,
            ),
          ),
        );
      },
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIcon({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      icon: Icon(icon, color: Colors.white, size: 25),
    );
  }
}

class _WatchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _WatchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SizedBox(
        width: 320,
        height: 59,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secButton,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            l10n.watch,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final MovieDetailsEntity movie;

  const _Stats({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.primaryButton, size: 19),
            text: '${movie.likeCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            icon: const Icon(
              Icons.access_time_filled_rounded,
              color: AppColors.primaryButton,
              size: 19,
            ),
            text: '${movie.runtime}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            icon: SvgPicture.asset(AppAssets.rate, width: 19, height: 19),
            text: movie.rating.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final Widget icon;
  final String text;

  const _Stat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Screenshots extends StatelessWidget {
  final List<String> screenshots;

  const _Screenshots({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: screenshots.map((screenshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: AspectRatio(
              aspectRatio: 1.88,
              child: CachedNetworkImage(
  imageUrl: screenshot,
  fit: BoxFit.cover,
  memCacheWidth: 900,
  placeholder: (context, url) {
    return const ColoredBox(
      color: AppColors.darkSurface,
    );
  },
  errorWidget: (context, url, error) {
    return const ColoredBox(
      color: AppColors.darkSurface,
    );
  },
)
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CastList extends StatelessWidget {
  final List<CastEntity> cast;

  const _CastList({required this.cast});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: cast.map((actor) {
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child:CachedNetworkImage(
  imageUrl: actor.imageUrl,
  width: 50,
  height: 50,
  fit: BoxFit.cover,
  memCacheWidth: 100,
  placeholder: (context, url) {
    return const ColoredBox(
      color: Color(0xFF3A3A3A),
    );
  },
  errorWidget: (context, url, error) {
    return const ColoredBox(
      color: Color(0xFF3A3A3A),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Icon(
          Icons.person,
          color: Colors.white54,
        ),
      ),
    );
  },
)
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFFE3E3E3),
                      fontSize: 14,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(text: '${l10n.name} : '),
                      TextSpan(text: actor.name),
                      TextSpan(text: '\n${l10n.character} : '),
                      TextSpan(text: actor.character),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Genres extends StatelessWidget {
  final List<String> genres;

  const _Genres({required this.genres});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: genres.map((genre) {
        return SizedBox(
          width: 88,
          height: 27,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                genre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
