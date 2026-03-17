import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../map/map_filters.dart';
import '../../widgets/app_components.dart';
import 'home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final challengeList = app.challenges;
    final nextAchievement =
        app.achievementsInProgress.firstOrNull ??
        app.unlockedAchievements.firstOrNull;
    final nearby = app.nearbyChallenges;
    final categoryCounts = <String, int>{
      for (final category in const [
        'Cultural',
        'Nature',
        'Historical',
        'Adventure',
      ])
        category: challengeList
            .where((c) => normalizeCategory(c.category) == category)
            .length,
    };
    return GeoQuestShell(
      selectedTab: GeoQuestTab.home,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const HomeHeader(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StreakCard(),
                const SizedBox(height: 24),
                SectionTitleRow(l.dailyChallenge, trailing: '+ 5% XP'),
                const SizedBox(height: 12),
                if (app.dailyChallenge != null)
                  DailyChallengeCard(challenge: app.dailyChallenge!),
                const SizedBox(height: 24),
                SectionTitleRow(l.nextAchievement),
                const SizedBox(height: 12),
                if (nextAchievement != null)
                  AchievementCard(a: nextAchievement)
                else
                  EmptyStateCard(
                    icon: Icons.emoji_events_outlined,
                    title: l.emptyInProgressTitle,
                    body: l.emptyInProgressBody,
                  ),
                const SizedBox(height: 24),
                SectionTitleRow(l.nearbyChallenges, trailing: '${l.viewAll} ›'),
                const SizedBox(height: 12),
                if (nearby.isNotEmpty)
                  PrimaryCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: nearby
                          .map((c) => CompactChallengeTile(c: c))
                          .toList(),
                    ),
                  )
                else
                  EmptyStateCard(
                    icon: Icons.explore_outlined,
                    title: l.emptyChallengesTitle,
                    body: l.emptyChallengesBody,
                  ),
                const SizedBox(height: 24),
                SectionTitleRow(l.categories),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.85,
                  children: [
                    CategoryTile(
                      '🏛️',
                      l.categoryCultural,
                      l.challengesCount(categoryCounts['Cultural'].toString()),
                      AppColors.primary,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/map?category=Cultural&view=list',
                      ),
                    ),
                    CategoryTile(
                      '🌲',
                      l.categoryNature,
                      l.challengesCount(categoryCounts['Nature'].toString()),
                      AppColors.green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/map?category=Nature&view=list',
                      ),
                    ),
                    CategoryTile(
                      '🏰',
                      l.categoryHistorical,
                      l.challengesCount(
                        categoryCounts['Historical'].toString(),
                      ),
                      AppColors.orange,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/map?category=Historical&view=list',
                      ),
                    ),
                    CategoryTile(
                      '⛰️',
                      l.categoryAdventure,
                      l.challengesCount(categoryCounts['Adventure'].toString()),
                      AppColors.red,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/map?category=Adventure&view=list',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const ProgressSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
