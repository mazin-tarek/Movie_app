import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/movie_details_model.dart';

abstract class MovieDetailsRemoteDataSource {
  Future<MovieDetailsModel> getMovieDetails({required int movieId});
}

class MovieDetailsRemoteDataSourceImpl implements MovieDetailsRemoteDataSource {
  final Dio dio;

  MovieDetailsRemoteDataSourceImpl({required this.dio});

  @override
  Future<MovieDetailsModel> getMovieDetails({required int movieId}) async {
    final response = await dio.get(
      'movie_details.json',
      queryParameters: {
        'movie_id': movieId,
        'with_images': true,
        'with_cast': true,
      },
    );
    debugPrint(response.data.toString());

    final data = response.data['data']['movie'];
   

    return MovieDetailsModel.fromJson(data);
  }
}
