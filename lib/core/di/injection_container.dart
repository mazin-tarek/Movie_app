import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movieapp/core/cubits/splash_cubit.dart';
import 'package:movieapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:movieapp/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:movieapp/features/auth/data/repositories/auth_repository.dart';
import 'package:movieapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/movies/data/datasources/movie_details_remote_data_source.dart';
import 'package:movieapp/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movieapp/features/movies/data/datasources/search_remote_data_source.dart';
import 'package:movieapp/features/movies/data/repositories/movie_details_repository.dart';
import 'package:movieapp/features/movies/data/repositories/movie_repository.dart';
import 'package:movieapp/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movieapp/features/movies/data/repositories/search_repository.dart';
import 'package:movieapp/features/movies/domain/usecases/get_movie_details_usecase.dart';
import 'package:movieapp/features/movies/domain/usecases/get_movies_use_case.dart';
import 'package:movieapp/features/movies/domain/usecases/search_movies_use_case.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/movie_details_bloc.dart';
import 'package:movieapp/features/movies/presentation/bloc/search_bloc.dart';
import 'package:movieapp/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:movieapp/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:movieapp/features/watchlist/data/repositories/watchlist_repository.dart';
import 'package:movieapp/features/watchlist/domain/usecases/add_to_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/get_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/is_movie_in_watchlist.dart';
import 'package:movieapp/features/watchlist/domain/usecases/remove_from_watchlist.dart';
import 'package:movieapp/features/history/data/datasources/history_remote_data_source.dart';
import 'package:movieapp/features/history/data/repositories/history_repository.dart';
import 'package:movieapp/features/history/domain/usecases/add_to_history.dart';
import 'package:movieapp/features/history/domain/usecases/get_history.dart';
import 'package:movieapp/features/history/bloc/history_bloc.dart';
final sl = GetIt.instance;

Future<void> initDependencies() async {
  
sl.registerLazySingleton<Dio>(
  () => Dio(
    BaseOptions(
      baseUrl: 'https://movies-api.accel.li/api/v2/',
      headers: {
        'Accept': 'application/json',
      },
    ),
  ),
);

  //External  dependencies
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  

  //Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()));


  sl.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );


  // Repositories 
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      userRemoteDataSource: sl(),
    ),
  );

  // Cubits splash
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(authRepository: sl()),
  );

  sl.registerFactory<AuthBloc>(
  () => AuthBloc(
    authRepository: sl<AuthRepository>(),
  ),
);



sl.registerLazySingleton<MovieRemoteDataSource>(
  () => MovieRemoteDataSourceImpl(
    dio: sl<Dio>(),
  ),
);

sl.registerLazySingleton<MovieRepository>(
  () => MovieRepositoryImpl(
    remoteDataSource: sl<MovieRemoteDataSource>(),
  ),
);

sl.registerLazySingleton<GetMoviesUseCase>(
  () => GetMoviesUseCase(
    repository: sl<MovieRepository>(),
  ),
);

sl.registerFactory<MovieBloc>(
  () => MovieBloc(
    getMoviesUseCase: sl<GetMoviesUseCase>(),
  ),
);


sl.registerLazySingleton<MovieDetailsRemoteDataSource>(
  () => MovieDetailsRemoteDataSourceImpl(
    dio: sl<Dio>(),
  ),
);

sl.registerLazySingleton<MovieDetailsRepository>(
  () => MovieDetailsRepositoryImpl(
    remoteDataSource: sl<MovieDetailsRemoteDataSource>(),
  ),
);

sl.registerLazySingleton<GetMovieDetailsUseCase>(
  () => GetMovieDetailsUseCase(
    repository: sl<MovieDetailsRepository>(),
  ),
);

sl.registerFactory<MovieDetailsBloc>(
  () => MovieDetailsBloc(
    getMovieDetailsUseCase: sl<GetMovieDetailsUseCase>(),
  ),
);
sl.registerLazySingleton<SearchRemoteDataSource>(
  () => SearchRemoteDataSourceImpl(
    dio: sl<Dio>(),
  ),
);

sl.registerLazySingleton<SearchRepository>(
  () => SearchRepositoryImpl(
    remoteDataSource: sl<SearchRemoteDataSource>(),
  ),
);

sl.registerLazySingleton<SearchMoviesUseCase>(
  () => SearchMoviesUseCase(
    repository: sl<SearchRepository>(),
  ),
);

sl.registerFactory<SearchBloc>(
  () => SearchBloc(
    searchMoviesUseCase: sl<SearchMoviesUseCase>(),
  ),
);

  // Watchlist

  sl.registerLazySingleton<WatchlistRemoteDataSource>(
    () => WatchlistRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
      remoteDataSource: sl<WatchlistRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<AddToWatchlist>(
    () => AddToWatchlist(
      repository: sl<WatchlistRepository>(),
    ),
  );

  sl.registerLazySingleton<RemoveFromWatchlist>(
    () => RemoveFromWatchlist(
      repository: sl<WatchlistRepository>(),
    ),
  );

  sl.registerLazySingleton<IsMovieInWatchlist>(
    () => IsMovieInWatchlist(
      repository: sl<WatchlistRepository>(),
    ),
  );

  sl.registerLazySingleton<GetWatchlist>(
    () => GetWatchlist(
      repository: sl<WatchlistRepository>(),
    ),
  );

  sl.registerFactory<WatchlistBloc>(
    () => WatchlistBloc(
      addToWatchlist: sl<AddToWatchlist>(),
      removeFromWatchlist: sl<RemoveFromWatchlist>(),
      isMovieInWatchlist: sl<IsMovieInWatchlist>(),
      getWatchlist: sl<GetWatchlist>(),
    ),
  );
  // History

sl.registerLazySingleton<HistoryRemoteDataSource>(
  () => HistoryRemoteDataSourceImpl(
    firestore: sl<FirebaseFirestore>(),
  ),
);

sl.registerLazySingleton<HistoryRepository>(
  () => HistoryRepositoryImpl(
    remoteDataSource: sl<HistoryRemoteDataSource>(),
  ),
);

sl.registerLazySingleton<AddToHistory>(
  () => AddToHistory(
    repository: sl<HistoryRepository>(),
  ),
);

sl.registerLazySingleton<GetHistory>(
  () => GetHistory(
    repository: sl<HistoryRepository>(),
  ),
);

sl.registerFactory<HistoryBloc>(
  () => HistoryBloc(
    addToHistory: sl<AddToHistory>(),
    getHistory: sl<GetHistory>(),
  ),
);
  }
