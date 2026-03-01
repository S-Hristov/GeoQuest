import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/geo_models.dart';
import '../theme/app_theme.dart';

class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child, this.backgroundColor});
  final Widget child;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    ),
  );
}

class PrimaryCard extends StatelessWidget {
  const PrimaryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    elevation: 2,
    shadowColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.black45
        : Colors.black12,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.gradient = AppColors.actionGradient,
    this.foreground = Colors.white,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final Gradient gradient;
  final Color foreground;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? gradient : null,
        color: enabled ? null : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: TextButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: icon == null
              ? const SizedBox.shrink()
              : Icon(icon, color: foreground),
          label: Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: enabled ? foreground : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) => PrimaryCard(
    child: Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 10),
        Text(value, style: AppTextStyles.h3, maxLines: 1),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small.copyWith(fontSize: 11.5),
        ),
      ],
    ),
  );
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => PrimaryCard(
    child: Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(body, style: AppTextStyles.body, textAlign: TextAlign.center),
      ],
    ),
  );
}

class GeoQuestShell extends StatelessWidget {
  const GeoQuestShell({
    super.key,
    required this.selectedTab,
    required this.child,
  });
  final GeoQuestTab selectedTab;
  final Widget child;
  @override
  Widget build(BuildContext context) => MobileFrame(
    child: Scaffold(
      body: child,
      bottomNavigationBar: GeoQuestBottomNav(selectedTab: selectedTab),
    ),
  );
}

class GeoQuestBottomNav extends StatelessWidget {
  const GeoQuestBottomNav({super.key, required this.selectedTab});
  final GeoQuestTab selectedTab;
  @override
  Widget build(BuildContext context) {
    void go(GeoQuestTab tab) {
      if (tab != selectedTab) {
        Navigator.pushReplacementNamed(context, '/${tab.name}');
      }
    }

    final l = AppLocalizations.of(context);
    return NavigationBar(
      height: 76,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: Colors.transparent,
      selectedIndex: GeoQuestTab.values.indexOf(selectedTab),
      onDestinationSelected: (i) => go(GeoQuestTab.values[i]),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home, color: AppColors.primary),
          label: l.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.location_on, color: AppColors.primary),
          label: l.map,
        ),
        NavigationDestination(
          icon: const Icon(Icons.emoji_events_outlined),
          selectedIcon: const Icon(
            Icons.emoji_events,
            color: AppColors.primary,
          ),
          label: l.leaderboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: AppColors.primary),
          label: l.profile,
        ),
      ],
    );
  }
}

String difficultyLabel(BuildContext context, Difficulty d) => switch (d) {
  Difficulty.easy => AppLocalizations.of(context).easy,
  Difficulty.medium => AppLocalizations.of(context).medium,
  Difficulty.hard => AppLocalizations.of(context).hard,
};

String categoryLabel(BuildContext context, String category) {
  final normalized = _normalizeCategory(category);
  final l = AppLocalizations.of(context);
  return switch (normalized) {
    'Cultural' => l.categoryCultural,
    'Nature' => l.categoryNature,
    'Historical' => l.categoryHistorical,
    'Adventure' => l.categoryAdventure,
    _ => category,
  };
}

String achievementTitleLabel(BuildContext context, String title) {
  final l = AppLocalizations.of(context);
  return switch (title) {
    'First Steps' => l.achievementFirstSteps,
    'Challenge Seeker' => l.achievementChallengeSeeker,
    'Nature Explorer' => l.achievementNatureExplorer,
    'Nature Master' => l.achievementNatureMaster,
    'Culture Lover' => l.achievementCultureLover,
    'History Hunter' => l.achievementHistoryHunter,
    'Adventure Awaits' => l.achievementAdventureAwaits,
    'Streak Starter' => l.achievementStreakStarter,
    'Explorer' => l.achievementExplorer,
    'Mountain Climber' => l.achievementMountainClimber,
    _ => title,
  };
}

String achievementSubtitleLabel(BuildContext context, String subtitle) {
  final l = AppLocalizations.of(context);
  return switch (subtitle) {
    'Complete your first challenge' => l.achievementCompleteFirstChallenge,
    'Complete 5 nature challenges' => l.achievementCompleteFiveNature,
    'Complete 25 challenges' => l.achievementCompleteTwentyFive,
    'Complete all mountain challenges' => l.achievementCompleteAllMountain,
    'Complete 10 challenges' => l.achievementCompleteTen,
    'Complete 5 cultural challenges' => l.achievementCompleteFiveCultural,
    _ => subtitle,
  };
}

Color difficultyColor(Difficulty d) => switch (d) {
  Difficulty.easy => AppColors.green,
  Difficulty.medium => AppColors.orange,
  Difficulty.hard => AppColors.red,
};

String _normalizeCategory(String category) {
  final value = category.trim().toLowerCase();
  if (value == 'culture' || value == 'cultural') return 'Cultural';
  if (value == 'nature') return 'Nature';
  if (value == 'historical') return 'Historical';
  if (value == 'adventure') return 'Adventure';
  return category;
}
