import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/cubits/locale_cubit.dart';
import 'package:movieapp/core/cubits/theme_cubit.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/theme/app_theme.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:movieapp/features/auth/presentation/screens/login_screen.dart';
import 'package:movieapp/features/movies/presentation/screens/onboarding_screen.dart';
import 'package:movieapp/features/auth/presentation/screens/register_screen.dart';
import 'package:movieapp/features/movies/presentation/screens/splash_screen.dart';
import 'package:movieapp/features/movies/presentation/screens/home.dart';
import 'package:movieapp/features/movies/presentation/screens/main_screen.dart';
import 'package:movieapp/firebase_options.dart';
import 'package:movieapp/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => const ForgetPasswordScreen(),
    ),

    GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
    GoRoute(path: "/main", builder: (context, state) => const MainScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),

        BlocProvider(create: (context) => LocaleCubit()),

        BlocProvider(create: (context) => sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Movies App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: _router,
                locale: locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
