import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_details_entity.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {
  const MovieDetailsInitial();
}

class MovieDetailsLoading extends MovieDetailsState {
  const MovieDetailsLoading();
}

class MovieDetailsSuccess extends MovieDetailsState {
  final MovieDetailsEntity movie;

  const MovieDetailsSuccess({
    required this.movie,
  });

  @override
  List<Object?> get props => [movie];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  const MovieDetailsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}