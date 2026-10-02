class MovieDetailsEntity {
  final int id;
  final String title;
  final String titleEnglish;
  final int year;
  final double rating;
  final int runtime;

  final int likeCount;

  final String descriptionIntro;
  final String descriptionFull;

  final String trailerCode;

  final String language;
  final String mpaRating;

  final String backgroundImage;
  final String largeCoverImage;

  final List<String> genres;
  final List<String> screenshots;

  final List<CastEntity> cast;

  const MovieDetailsEntity({
    required this.id,
    required this.title,
    required this.titleEnglish,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.likeCount,
    required this.descriptionIntro,
    required this.descriptionFull,
    required this.trailerCode,
    required this.language,
    required this.mpaRating,
    required this.backgroundImage,
    required this.largeCoverImage,
    required this.genres,
    required this.screenshots,
    required this.cast,
  });
}

class CastEntity {
  final String name;
  final String character;
  final String imageUrl;

  const CastEntity({
    required this.name,
    required this.character,
    required this.imageUrl,
  });
}