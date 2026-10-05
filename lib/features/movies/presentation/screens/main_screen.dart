import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/widgets/app_bottom_nav_bar.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_event.dart';
import 'package:movieapp/features/movies/presentation/bloc/search_bloc.dart';
import 'package:movieapp/features/movies/presentation/screens/browse_screen.dart';
import 'package:movieapp/features/movies/presentation/screens/home.dart';
import 'package:movieapp/features/movies/presentation/screens/search_screen.dart';
import 'package:movieapp/features/movies/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _profileKey = GlobalKey<ProfileScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),

    BlocProvider(create: (_) => sl<SearchBloc>(), child: const SearchScreen()),
    BlocProvider(
      create: (_) =>
          sl<MovieBloc>()
            ..add(GetMoviesByGenreRequested(genre: 'Action', page: 1)),
      child: BrowseScreen(),
    ),
    ProfileScreen(key: _profileKey),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= _screens.length) return;

          if (index == 3) {
            _profileKey.currentState?.refreshCollections();
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
