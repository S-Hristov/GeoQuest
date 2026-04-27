import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../profile/profile_avatar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final user = app.currentUser;
    final unread = app.unreadNotificationCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.welcomeBackShort,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: AppTextStyles.h1.copyWith(fontSize: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              ProfileAvatar(
                user: user,
                radius: 28,
                textStyle: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white),
                    Text(
                      l.levelWord,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${user.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.totalPoints,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      l.nextLevel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${user.points}',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    Text(
                      l.pointsPts(
                        (user.nextLevelPoints - user.points).toString(),
                      ),
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: user.points / user.nextLevelPoints,
                  borderRadius: BorderRadius.circular(99),
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
