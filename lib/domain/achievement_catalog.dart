import '../models/geo_models.dart';

typedef AchievementCatalogEntry = ({
  String id,
  String title,
  String subtitle,
  String icon,
  int total,
});

const achievementCatalog = <AchievementCatalogEntry>[
  (
    id: 'first_challenge',
    title: 'First Steps',
    subtitle: 'Complete your first challenge',
    icon: '🏆',
    total: 1,
  ),
  (
    id: 'five_challenges',
    title: 'Challenge Seeker',
    subtitle: 'Complete 5 challenges',
    icon: '🎯',
    total: 5,
  ),
  (
    id: 'first_nature',
    title: 'Nature Explorer',
    subtitle: 'Complete your first nature challenge',
    icon: '🌲',
    total: 1,
  ),
  (
    id: 'first_cultural',
    title: 'Culture Lover',
    subtitle: 'Complete your first cultural challenge',
    icon: '🏛️',
    total: 1,
  ),
  (
    id: 'first_historical',
    title: 'History Hunter',
    subtitle: 'Complete your first historical challenge',
    icon: '🏰',
    total: 1,
  ),
  (
    id: 'first_adventure',
    title: 'Adventure Awaits',
    subtitle: 'Complete your first adventure challenge',
    icon: '⛰️',
    total: 1,
  ),
  (
    id: 'three_day_streak',
    title: 'Streak Starter',
    subtitle: 'Reach a 3-day streak',
    icon: '🔥',
    total: 3,
  ),
];

Achievement achievementFromCatalog(
  AchievementCatalogEntry entry, {
  required int progress,
  required String unlocked,
}) => Achievement(
  title: entry.title,
  subtitle: entry.subtitle,
  icon: entry.icon,
  progress: progress,
  total: entry.total,
  unlocked: unlocked,
);
