import '../../domain/entities/movie_details_entity.dart';

class MovieDetailsModel extends MovieDetailsEntity {
  const MovieDetailsModel({
    required super.id,
    required super.title,
    required super.titleEnglish,
    required super.year,
    required super.rating,
    required super.runtime,
    required super.likeCount,
    required super.descriptionIntro,
    required super.descriptionFull,
    required super.trailerCode,
    required super.language,
    required super.mpaRating,
    required super.backgroundImage,
    required super.largeCoverImage,
    required super.genres,
    required super.screenshots,
    required super.cast,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,

      title: json['title'] is String
          ? json['title']
          : '',

      titleEnglish: json['title_english'] is String
          ? json['title_english']
          : '',

      year: json['year'] is num
          ? (json['year'] as num).toInt()
          : 0,

      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : 0,

      runtime: json['runtime'] is num
          ? (json['runtime'] as num).toInt()
          : 0,

      likeCount: json['like_count'] is num
          ? (json['like_count'] as num).toInt()
          : 0,

      descriptionIntro: json['description_intro'] is String
          ? json['description_intro']
          : '',

      descriptionFull: json['description_full'] is String
          ? json['description_full']
          : '',

      trailerCode: json['yt_trailer_code'] is String
          ? json['yt_trailer_code']
          : '',

      language: json['language'] is String
          ? json['language']
          : '',

      mpaRating: json['mpa_rating'] is String
          ? json['mpa_rating']
          : '',

      backgroundImage: json['background_image'] is String
          ? json['background_image']
          : '',

      largeCoverImage: json['large_cover_image'] is String
          ? json['large_cover_image']
          : '',

      genres: json['genres'] is List
          ? List<String>.from(
              (json['genres'] as List).whereType<String>(),
            )
          : [],

      screenshots: [
        json['large_screenshot_image1'],
        json['large_screenshot_image2'],
        json['large_screenshot_image3'],
      ].whereType<String>().toList(),

      cast: json['cast'] is List
          ? (json['cast'] as List)
              .whereType<Map>()
              .map(
                (actor) => CastModel.fromJson(
                  Map<String, dynamic>.from(actor),
                ),
              )
              .toList()
          : [],
    );
  }
}

class CastModel extends CastEntity {
  const CastModel({
    required super.name,
    required super.character,
    required super.imageUrl,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] is String
          ? json['name']
          : '',

      character: json['character_name'] is String
          ? json['character_name']
          : '',

      imageUrl: json['url_small_image'] is String
          ? json['url_small_image']
          : '',
    );
  }
}