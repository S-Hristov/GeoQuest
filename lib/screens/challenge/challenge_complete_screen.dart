import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ChallengeCompleteScreen extends StatelessWidget {
  const ChallengeCompleteScreen({super.key, required this.challenge});
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<AppState>().currentUser;
    final remaining = (user.nextLevelPoints - user.points).clamp(0, 1 << 30);
    return MobileFrame(
      backgroundColor: AppColors.magenta,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.successGradient),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                final side = compact ? 20.0 : 28.0;
                final iconRadius = compact ? 48.0 : 62.0;
                final iconSize = compact ? 54.0 : 70.0;
                final titleStyle = compact
                    ? AppTextStyles.h2
                    : AppTextStyles.h1;
                final titleGap = compact ? 6.0 : 10.0;
                final topGap = compact ? 12.0 : 26.0;
                final blockGap = compact ? 18.0 : 30.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(side, side, side, 10),
                  child: Column(
                    children: [
                      SizedBox(height: topGap),
                      CircleAvatar(
                        radius: iconRadius,
                        backgroundColor: AppColors.orange,
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                      SizedBox(height: compact ? 18 : 28),
                      Text(
                        l.challengeCompleteCongrats,
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                      SizedBox(height: titleGap),
                      Text(
                        l.challengeCompleteSuccess,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                      SizedBox(height: compact ? 20 : 34),
                      PrimaryCard(
                        padding: EdgeInsets.all(compact ? 14 : 20),
                        child: Column(
                          children: [
                            Text(l.yourRewards, style: AppTextStyles.h2),
                            SizedBox(height: compact ? 10 : 20),
                            Text(
                              '+${challenge.points}',
                              style: TextStyle(
                                color: AppColors.magenta,
                                fontSize: compact ? 34 : 40,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l.pointsEarnedLabel,
                              style: AppTextStyles.body,
                            ),
                            SizedBox(height: compact ? 12 : 20),
                            PrimaryCard(
                              color: Theme.of(context).cardColor,
                              padding: EdgeInsets.all(compact ? 10 : 14),
                              child: ListTile(
                                dense: compact,
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
                                subtitle: Text(
                                  l.badgeUnlockedForCompletingChallenge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: blockGap),
                      Container(
                        padding: EdgeInsets.all(compact ? 14 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
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
                      SizedBox(height: blockGap),
                      FilledButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (r) => false,
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(compact ? 50 : 58),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(l.continueExploring),
                      ),
                      SizedBox(height: compact ? 14 : 22),
                      Text(
                        remaining == 0
                            ? l.reachedNewLevel
                            : l.pointsUntilNextLevel(
                                remaining.toString(),
                                (user.level + 1).toString(),
                              ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
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
