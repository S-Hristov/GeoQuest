import '../../models/geo_models.dart';

String normalizeCategory(String value) {
  final lower = value.trim().toLowerCase();
  return switch (lower) {
    'culture' || 'cultural' => 'Cultural',
    'nature' => 'Nature',
    'historical' || 'history' => 'Historical',
    'adventure' => 'Adventure',
    _ => value,
  };
}

class ChallengeFilters {
  const ChallengeFilters({this.difficulty, this.category, this.maxDistanceKm});

  final Difficulty? difficulty;
  final String? category;
  final double? maxDistanceKm;

  bool get isEmpty =>
      difficulty == null && category == null && maxDistanceKm == null;

  ChallengeFilters copyWith({
    Difficulty? difficulty,
    String? category,
    double? maxDistanceKm,
    bool clearDifficulty = false,
    bool clearCategory = false,
    bool clearDistance = false,
  }) => ChallengeFilters(
    difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
    category: clearCategory ? null : category ?? this.category,
    maxDistanceKm: clearDistance ? null : maxDistanceKm ?? this.maxDistanceKm,
  );

  bool matches(Challenge challenge) {
    if (difficulty != null && challenge.difficulty != difficulty) return false;
    if (category != null &&
        normalizeCategory(challenge.category) != normalizeCategory(category!)) {
      return false;
    }
    if (maxDistanceKm != null && challenge.distanceKm > maxDistanceKm!) {
      return false;
    }
    return true;
  }
}
