import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({
    required this.entry,
    required this.height,
    this.isFirst = false,
  });
  final LeaderboardEntry entry;
  final double height;
  final bool isFirst;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black45
                : Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: isFirst ? 34 : 28,
            backgroundColor: isFirst
                ? AppColors.yellow
                : Theme.of(context).cardColor,
            child: Text(
              entry.initials,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            isFirst ? Icons.workspace_premium : Icons.military_tech,
            color: isFirst
                ? AppColors.orange
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text('${entry.rank}', style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              entry.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Text('${entry.points}', style: const TextStyle(fontSize: 20)),
          Text(
            AppLocalizations.of(context).pointsWord,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class LeaderboardRankRow extends StatelessWidget {
  const LeaderboardRankRow(this.e);
  final LeaderboardEntry e;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: PrimaryCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: Text(
              '#${e.rank}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  AppLocalizations.of(context).leaderboardLevelCompleted(
                    e.level.toString(),
                    e.completed.toString(),
                  ),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${e.points}', style: AppTextStyles.h3),
              Text(
                AppLocalizations.of(context).pointsWord,
                style: AppTextStyles.small,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
