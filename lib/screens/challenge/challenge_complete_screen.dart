import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ChallengeCompleteScreen extends StatelessWidget {
  const ChallengeCompleteScreen({
    super.key,
    required this.challenge,
    this.prevLevel,
    this.prevPoints,
  });
  final Challenge challenge;
  final int? prevLevel;
  final int? prevPoints;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final user = app.currentUser;
    final didLevelUp = prevLevel != null && user.level > prevLevel!;
    final totalEarned = prevPoints == null
        ? challenge.points
        : (user.points - prevPoints!).clamp(0, 1 << 30);
    final unlockedNow = app.lastCompletionUnlockedAchievements;
    final achievementBonusFromBadges = unlockedNow.fold<int>(
      0,
      (sum, a) => sum + a.rewardPoints,
    );
    final achievementBonus = (totalEarned - challenge.points) > 0
        ? (totalEarned - challenge.points)
        : achievementBonusFromBadges;

    return MobileFrame(
      backgroundColor: AppColors.magenta,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.successGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.orange,
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.challengeCompleteCongrats,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.challengeCompleteSuccess,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  PrimaryCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l.yourRewards, style: AppTextStyles.h2),
                        const SizedBox(height: 10),
                        Text(
                          '+$totalEarned',
                          style: const TextStyle(
                            color: AppColors.magenta,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(l.pointsEarnedLabel, style: AppTextStyles.body),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              _BreakdownRow('Challenge', challenge.points),
                              _BreakdownRow('Achievements', achievementBonus),
                              const Divider(height: 16),
                              _BreakdownRow('Total', totalEarned, emphasize: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (unlockedNow.isNotEmpty) ...[
                          for (final a in unlockedNow)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: PrimaryCard(
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  dense: true,
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.orange,
                                    child: Text('🏆'),
                                  ),
                                  title: Text(
                                    a.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    l.badgeUnlockedForCompletingChallenge,
                                  ),
                                  trailing: Text(
                                    '+${a.rewardPoints}',
                                    style: const TextStyle(
                                      color: AppColors.magenta,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ] else
                          PrimaryCard(
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              dense: true,
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.orange,
                                child: Text('🏆'),
                              ),
                              title: Text(
                                l.achievementFirstSteps,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(l.badgeUnlockedForCompletingChallenge),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WhiteStat('${user.completed}', l.totalCompleted),
                        _WhiteStat('${user.points}', l.totalPoints),
                        _WhiteStat('${user.level}', l.currentLevel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => didLevelUp
                        ? Navigator.pushReplacementNamed(
                            context,
                            '/level-up/${user.level}',
                          )
                        : Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (r) => false,
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      didLevelUp ? '⚡ ${l.reachedNewLevel}' : l.continueExploring,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteStat extends StatelessWidget {
  const _WhiteStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    ],
  );
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(this.label, this.points, {this.emphasize = false});

  final String label;
  final int points;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      const Spacer(),
      Text(
        '+$points',
        style: TextStyle(
          color: AppColors.magenta,
          fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
    ],
  );
}
