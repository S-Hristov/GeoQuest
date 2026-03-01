import 'package:flutter/material.dart';

enum GeoQuestTab { home, map, leaderboard, profile }

enum ChallengeStatus {
  ready,
  tooFar,
  locationPermissionRequired,
  locationReached,
}

enum ActiveChallengeStatus { active, completed, abandoned }

enum Difficulty { easy, medium, hard }

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.easy => 'easy',
    Difficulty.medium => 'medium',
    Difficulty.hard => 'hard',
  };
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initials,
    required this.level,
    required this.points,
    required this.nextLevelPoints,
    required this.completed,
    required this.badges,
    required this.bestStreak,
    required this.currentStreak,
    required this.email,
    this.avatarPath,
    this.lastCompletedDate,
  });
  final String name;
  final String initials;
  final int level;
  final int points;
  final int nextLevelPoints;
  final int completed;
  final int badges;
  final int bestStreak;
  final int currentStreak;
  final String email;
  final String? avatarPath;
  final DateTime? lastCompletedDate;
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.imageAsset,
    required this.distanceKm,
    required this.points,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.explorersCompleted,
  });
  final String id;
  final String title;
  final String location;
  final String description;
  final String imageAsset;
  final double distanceKm;
  final int points;
  final String duration;
  final Difficulty difficulty;
  final String category;
  final double latitude;
  final double longitude;
  final int explorersCompleted;
}

class ActiveChallengeState {
  const ActiveChallengeState({
    required this.challengeId,
    required this.startedAt,
    required this.status,
    this.lastRouteShownAt,
  });

  final String challengeId;
  final DateTime startedAt;
  final ActiveChallengeStatus status;
  final DateTime? lastRouteShownAt;

  ActiveChallengeState copyWith({
    String? challengeId,
    DateTime? startedAt,
    ActiveChallengeStatus? status,
    DateTime? lastRouteShownAt,
    bool clearLastRouteShownAt = false,
  }) => ActiveChallengeState(
    challengeId: challengeId ?? this.challengeId,
    startedAt: startedAt ?? this.startedAt,
    status: status ?? this.status,
    lastRouteShownAt: clearLastRouteShownAt
        ? null
        : lastRouteShownAt ?? this.lastRouteShownAt,
  );
}

class Achievement {
  const Achievement({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.rewardPoints = 0,
    required this.progress,
    required this.total,
    required this.unlocked,
  });
  final String title;
  final String subtitle;
  final String icon;
  final int rewardPoints;
  final int progress;
  final int total;
  final String unlocked;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.initials,
    required this.level,
    required this.completed,
    required this.points,
    this.color = const Color(0xFFEDEFF5),
  });
  final int rank;
  final String name;
  final String initials;
  final int level;
  final int completed;
  final int points;
  final Color color;
}
