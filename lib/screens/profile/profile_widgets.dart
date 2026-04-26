import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ProfileStreakCard extends StatelessWidget {
  const ProfileStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<AppState>().currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.daysCount(user.currentStreak.toString()),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  l.currentStreak,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            l.bestCount(user.bestStreak.toString()),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ProfileProgressAchievement extends StatelessWidget {
  const ProfileProgressAchievement(this.a, {super.key});
  final Achievement a;
  @override
  Widget build(BuildContext context) => PrimaryCard(
    child: Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.green.withValues(alpha: .1),
          child: Text(a.icon, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievementTitleLabel(context, a.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                achievementSubtitleLabel(context, a.subtitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: a.progress / a.total,
                color: AppColors.primary,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(99),
              ),
            ],
          ),
        ),
        Text('${a.progress}/${a.total}', style: AppTextStyles.small),
      ],
    ),
  );
}

class ProfileUnlockTile extends StatelessWidget {
  const ProfileUnlockTile(this.a, {super.key});
  final Achievement a;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subtitle = achievementSubtitleLabel(context, a.subtitle);
    return PrimaryCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.green.withValues(alpha: .1),
            child: Text(a.icon),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievementTitleLabel(context, a.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  l.achievementUnlocked(subtitle, a.unlocked),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCompletedChallenge extends StatelessWidget {
  const ProfileCompletedChallenge(this.c, {super.key});
  final Challenge c;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PrimaryCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadius.lg),
            ),
            child: Image.asset(
              c.imageAsset,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${c.location}\n${l.completedCheck}',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              l.pointsPts(c.points.toString()),
              style: const TextStyle(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}
