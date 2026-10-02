class MovieEntity {
  final int id;
  final String title;
  final String titleEnglish;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String backgroundImage;
  final String mediumCoverImage;
  final String largeCoverImage;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.titleEnglish,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.backgroundImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
  });
}