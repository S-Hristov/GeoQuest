import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'profile_avatar.dart';
import 'profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final user = app.currentUser;
    final completed = app.challenges.where(
      (c) => app.isChallengeCompleted(c.id),
    );
    final remaining = (user.nextLevelPoints - user.points).clamp(0, 1 << 30);
    return GeoQuestShell(
      selectedTab: GeoQuestTab.profile,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
            child: Column(
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      user: user,
                      radius: 40,
                      backgroundColor: Colors.white24,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTextStyles.h1.copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.profileLevelExplorer(user.level.toString()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l.levelValue(user.level.toString())),
                          Text(
                            l.pointsProgress(
                              user.points.toString(),
                              user.nextLevelPoints.toString(),
                            ),
                            style: AppTextStyles.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      LinearProgressIndicator(
                        value: user.points / user.nextLevelPoints,
                        color: AppColors.primary,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l.pointsToLevel(
                            remaining.toString(),
                            (user.level + 1).toString(),
                          ),
                          style: AppTextStyles.small,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileStreakCard(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.emoji_events_outlined,
                        value: '${user.points}',
                        label: l.totalPoints,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.location_on_outlined,
                        value: '${user.completed}',
                        label: l.completed,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.workspace_premium_outlined,
                        value: '${user.badges}',
                        label: l.badges,
                        color: AppColors.primary2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l.inProgress, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                if (app.achievementsInProgress.isEmpty)
                  EmptyStateCard(
                    icon: Icons.rocket_launch_outlined,
                    title: l.emptyInProgressTitle,
                    body: l.emptyInProgressBody,
                  )
                else
                  ...app.achievementsInProgress.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileProgressAchievement(a),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(l.recentUnlocks, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                if (app.unlockedAchievements.isEmpty)
                  EmptyStateCard(
                    icon: Icons.workspace_premium_outlined,
                    title: l.emptyUnlocksTitle,
                    body: l.emptyUnlocksBody,
                  )
                else
                  ...app.unlockedAchievements.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileUnlockTile(a),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(l.completedChallenges, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                if (completed.isEmpty)
                  EmptyStateCard(
                    icon: Icons.map_outlined,
                    title: l.emptyCompletedChallengesTitle,
                    body: l.emptyCompletedChallengesBody,
                  )
                else
                  ...completed.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileCompletedChallenge(c),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
