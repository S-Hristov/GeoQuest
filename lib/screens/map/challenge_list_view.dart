import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ChallengeListView extends StatelessWidget {
  const ChallengeListView({super.key, required this.challenges});

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text(l.nearbyChallenges, style: AppTextStyles.h2)),
            Text('${challenges.length} found', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 12),
        if (challenges.isEmpty)
          EmptyStateCard(
            icon: Icons.explore_off_outlined,
            title: l.emptyChallengesTitle,
            body: l.emptyChallengesBody,
          )
        else
          ...challenges.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PrimaryCard(
                padding: EdgeInsets.zero,
                onTap: () => Navigator.pushNamed(context, '/challenge/${c.id}'),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.lg),
                      ),
                      child: Image.asset(
                        c.imageAsset,
                        width: 116,
                        height: 118,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: AppTextStyles.h3),
                            Text(
                              c.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                StatusChip(
                                  text: difficultyLabel(context, c.difficulty),
                                  color: difficultyColor(c.difficulty),
                                ),
                                if (app.isChallengeActive(c.id))
                                  StatusChip(
                                    text: l.challengeStateActive,
                                    color: AppColors.primary,
                                  )
                                else if (app.isChallengeCompleted(c.id))
                                  StatusChip(
                                    text: l.challengeStateCompleted,
                                    color: AppColors.green,
                                  ),
                                Text(
                                  categoryLabel(context, c.category),
                                  style: AppTextStyles.small,
                                ),
                                Text(
                                  l.pointsPts(c.points.toString()),
                                  style: const TextStyle(
                                    color: AppColors.primary,
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
              ),
            ),
          ),
      ],
    );
  }
}
