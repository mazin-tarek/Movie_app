import 'package:equatable/equatable.dart';

import '../../domain/entities/movie_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<MovieEntity> movies;
  final int page;
  final String query;

  const SearchSuccess({
    required this.movies,
    required this.page,
    required this.query,
  });

  @override
  List<Object?> get props => [movies, page, query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}