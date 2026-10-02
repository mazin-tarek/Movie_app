import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchMoviesRequested extends SearchEvent {
  final String query;
  final int page;

  const SearchMoviesRequested({
    required this.query,
    this.page = 1,
  });

  @override
  List<Object?> get props => [query, page];
}