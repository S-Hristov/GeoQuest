import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markAllNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notifications = context.watch<AppState>().notifications;
    return MobileFrame(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.notifications),
          centerTitle: false,
        ),
        body: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.noNotificationsYet,
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _NotificationTile(n: notifications[i]),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.n});
  final AppNotification n;

  IconData _icon() => switch (n.type) {
    'complete_summary' => Icons.emoji_events,
    'achievement_unlock' => Icons.star,
    'streak_milestone' || 'streak_risk' => Icons.local_fire_department,
    'daily_challenge' => Icons.today,
    'nearby_nudge' => Icons.location_on,
    'leaderboard_move' => Icons.leaderboard,
    'weekly_recap' => Icons.bar_chart,
    'reengagement' => Icons.explore,
    _ => Icons.notifications,
  };

  Color _color() => switch (n.type) {
    'complete_summary' => AppColors.orange,
    'achievement_unlock' => AppColors.yellow,
    'streak_milestone' || 'streak_risk' => AppColors.orange,
    'daily_challenge' => AppColors.primary,
    'nearby_nudge' => AppColors.green,
    'leaderboard_move' => AppColors.magenta,
    'weekly_recap' => AppColors.primary2,
    _ => AppColors.muted,
  };

  String _timeAgo(BuildContext context, DateTime dt) {
    final l = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l.timeJustNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    return l.timeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _color().withValues(alpha: .15),
            child: Icon(_icon(), color: _color(), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 2),
                Text(n.body, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(context, n.receivedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
