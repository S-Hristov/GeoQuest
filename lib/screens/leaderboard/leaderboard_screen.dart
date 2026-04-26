import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'leaderboard_widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = context.watch<AppState>().leaderboard;
    final user = context.watch<AppState>().currentUser;
    final currentRank = _currentRank(entries, user);
    final podium = entries.take(3).toList();
    final rest = entries.length > 3
        ? entries.skip(3).toList()
        : const <LeaderboardEntry>[];

    return GeoQuestShell(
      selectedTab: GeoQuestTab.leaderboard,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 54, 24, 26),
            decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.leaderboard,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Text(
                  l.leaderboardSubtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: EmptyStateCard(
                icon: Icons.emoji_events_outlined,
                title: l.emptyLeaderboardTitle,
                body: l.emptyLeaderboardBody,
              ),
            )
          else if (podium.length >= 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LeaderboardPodium(entry: podium[1], height: 285),
                  ),
                  Expanded(
                    child: LeaderboardPodium(
                      entry: podium[0],
                      height: 345,
                      isFirst: true,
                    ),
                  ),
                  Expanded(
                    child: LeaderboardPodium(entry: podium[2], height: 285),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.allRankings, style: AppTextStyles.h2),
                const SizedBox(height: 14),
                ...rest.map(LeaderboardRankRow.new),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.yourCurrentRank,
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '#$currentRank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l.keepExploringHigher,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryCard(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '💡 ${l.leaderboardTip}',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _currentRank(List<LeaderboardEntry> entries, UserProfile user) {
    final index = entries.indexWhere(
      (entry) => entry.name == user.name && entry.initials == user.initials,
    );
    if (index >= 0) return index + 1;
    return entries.length + 1;
  }
}
