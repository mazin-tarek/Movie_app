import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/movie_skeleton.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:movieapp/features/auth/presentation/screens/update_profile_screen.dart';
import 'package:movieapp/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/l10n/app_localizations.dart';

import 'package:movieapp/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_event.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_state.dart';

import 'package:movieapp/features/history/bloc/history_bloc.dart';
import 'package:movieapp/features/history/bloc/history_event.dart';
import 'package:movieapp/features/history/bloc/history_state.dart';

import 'package:movieapp/features/movies/domain/entities/movie_entity.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_event.dart';
import 'package:movieapp/features/movies/presentation/screens/movie_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserEntity? _currentUser;
  WatchlistBloc? _watchlistBloc;
  HistoryBloc? _historyBloc;

  void refreshCollections() {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted || user == null) return;

    _watchlistBloc?.add(GetWatchlistRequested(userId: user.uid));
    _historyBloc?.add(GetHistoryRequested(userId: user.uid));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<WatchlistBloc>();
            _watchlistBloc = bloc;

            if (user != null) {
              bloc.add(GetWatchlistRequested(userId: user.uid));
            }

            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = sl<HistoryBloc>();
            _historyBloc = bloc;

            if (user != null) {
              bloc.add(GetHistoryRequested(userId: user.uid));
            }

            return bloc;
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                _currentUser = state.user;
              }

              if (state is Unauthenticated) {
                _tabController.index = 0;
                context.go('/login');
              }
            },
            builder: (context, state) {
              if (state is AuthLoading || state is AuthInitial) {
                return const Center(
                  child: MovieSkeletonBox(
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                );
              }

              final user = state is Authenticated ? state.user : _currentUser;

              return _ProfileContent(user: user, tabController: _tabController);
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserEntity? user;
  final TabController tabController;

  const _ProfileContent({required this.user, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = user?.name?.trim().isNotEmpty == true
        ? user!.name!
        : '';

    return Column(
      children: [
        Container(
          color: const Color(0xFF202020),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.profile,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ProfileAvatar(avatarPath: user?.avatar),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              BlocBuilder<WatchlistBloc, WatchlistState>(
                                builder: (context, state) {
                                  final count = state is WatchlistLoaded
                                      ? state.movies.length
                                      : 0;

                                  return _ProfileStat(
                                    value: count.toString(),
                                    label: l10n.watchlist,
                                  );
                                },
                              ),

                              BlocBuilder<HistoryBloc, HistoryState>(
                                builder: (context, state) {
                                  final count = state is HistoryLoaded
                                      ? state.movies.length
                                      : 0;

                                  return _ProfileStat(
                                    value: count.toString(),
                                    label: l10n.history,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ActionButton(
                            label: l10n.editProfile,
                            color: AppColors.primaryButton,
                            foregroundColor: Colors.black,
                            onPressed: user == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UpdateProfileScreen(user: user!),
                                      ),
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          flex: 1,
                          child: _ActionButton(
                            label: l10n.logout,
                            color: AppColors.secButton,
                            foregroundColor: Colors.white,
                            icon: Icons.logout_rounded,
                            onPressed: () {
                              context.read<AuthBloc>().add(SignOutRequested());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileTabs(controller: tabController),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [_WatchlistTab(), _HistoryTab()],
          ),
        ),
      ],
    );
  }
}

void _refreshCollections(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  context.read<WatchlistBloc>().add(GetWatchlistRequested(userId: user.uid));
  context.read<HistoryBloc>().add(GetHistoryRequested(userId: user.uid));
}

class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state is WatchlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WatchlistError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is WatchlistLoaded) {
          if (state.movies.isEmpty) {
            return _EmptyCollection(
              iconPath: AppAssets.watchlist,
              message: l10n.watchlistEmpty,
            );
          }

          return _MovieGrid(
            movies: state.movies,
            onReturn: () => _refreshCollections(context),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistoryError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is HistoryLoaded) {
          if (state.movies.isEmpty) {
            return _EmptyCollection(
              iconPath: AppAssets.history,
              message: l10n.historyEmpty,
            );
          }

          return _MovieGrid(
            movies: state.movies,
            onReturn: () => _refreshCollections(context),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _MovieGrid extends StatelessWidget {
  final List<MovieEntity> movies;
  final VoidCallback onReturn;

  const _MovieGrid({required this.movies, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];

        return GestureDetector(
          onTap: () {
            final bloc = sl<MovieDetailsBloc>();

            bloc.add(GetMovieDetailsRequested(movieId: movie.id));

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: MovieDetailsScreen(movie: movie, onReturn: onReturn),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              movie.mediumCoverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFF242424),
                  child: const Icon(
                    Icons.movie_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarPath;

  const _ProfileAvatar({required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath != null && avatarPath!.isNotEmpty;
    return CircleAvatar(
      radius: 40,
      backgroundColor: const Color(0xFF242424),
      backgroundImage: hasAvatar ? AssetImage(avatarPath!) : null,
      child: hasAvatar
          ? null
          : const Icon(
              Icons.person_outline_rounded,
              color: Colors.white54,
              size: 34,
            ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundColor;
  final IconData? icon;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.foregroundColor,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (icon != null) ...[
              const SizedBox(width: 7),
              Icon(icon, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final TabController controller;

  const _ProfileTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 72,
      child: TabBar(
        controller: controller,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryButton,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            icon: SvgPicture.asset(AppAssets.watchlist, width: 20, height: 20),
            text: l10n.watchlist,
          ),
          Tab(
            icon: SvgPicture.asset(AppAssets.history, width: 20, height: 20),
            text: l10n.history,
          ),
        ],
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  final String iconPath;
  final String message;

  const _EmptyCollection({required this.iconPath, required this.message});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth * 0.22).clamp(70.0, 90.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.empty,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ],
          ),
        );
      },
    );
  }
}
