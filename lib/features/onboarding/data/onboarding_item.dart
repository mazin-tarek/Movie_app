class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });


}

 List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    image: 'assets/images/moviepostersgroup.png',
    title: 'Find Your Next Favorite Movie Here',
    description:
        'Get access to a huge library of movies to suit all tastes. You will surely like it.',
  ),
  OnboardingItem(
    image: 'assets/images/1onboarding.png',
    title: 'Discover Movies',
    description:
        'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
  ),
  OnboardingItem(
    image: 'assets/images/2onboarding.png',
    title: 'Explore All Genres',
    description:
        'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
  ),
  OnboardingItem(
    image: 'assets/images/3onboarding.png',
    title: 'Create Watchlists',
    description:
        'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
  ),
  OnboardingItem(
    image: 'assets/images/4onboarding.png',
    title: 'Rate, Review, and Learn',
    description:
        'Share your thoughts on the movies you\'ve watched. Dive deep into film details and help others discover great movies with your reviews.',
  ),

  OnboardingItem(
    image: 'assets/images/5onboarding.png',
    title: 'Start Watching Now',
    description:
        ' '
  ),
];
