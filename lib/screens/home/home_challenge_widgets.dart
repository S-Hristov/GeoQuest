import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<AppState>().currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dayStreak(user.currentStreak.toString()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l.keepItGoing,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            l.bestDays(user.bestStreak.toString()),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow(this.title, {this.trailing, super.key});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: AppTextStyles.h2)),
      if (trailing != null)
        Text(trailing!, style: const TextStyle(color: AppColors.primary)),
    ],
  );
}

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({required this.challenge, super.key});
  final Challenge challenge;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PrimaryCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.pushNamed(context, '/challenge/${challenge.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadius.lg),
            ),
            child: Image.asset(
              challenge.imageAsset,
              width: 132,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    l.dailyChallengeDistanceAway(
                      challenge.distanceKm.toString(),
                    ),
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusChip(
                        text: difficultyLabel(context, challenge.difficulty),
                        color: difficultyColor(challenge.difficulty),
                      ),
                      Text(
                        l.pointsPts(challenge.points.toString()),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactChallengeTile extends StatelessWidget {
  const CompactChallengeTile({required this.c, super.key});
  final Challenge c;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/challenge/${c.id}'),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                c.imageAsset,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l.distanceAway(c.distanceKm.toString()),
                    style: AppTextStyles.small,
                  ),
                  StatusChip(
                    text: difficultyLabel(context, c.difficulty),
                    color: difficultyColor(c.difficulty),
                  ),
                ],
              ),
            ),
            Text(
              l.pointsPts(c.points.toString()),
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  const AchievementCard({required this.a, super.key});
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
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                achievementSubtitleLabel(context, a.subtitle),
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
