import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ChallengeStartedScreen extends StatelessWidget {
  const ChallengeStartedScreen({
    super.key,
    required this.challenge,
    this.showBackToMap = false,
  });

  final Challenge challenge;
  final bool showBackToMap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = context.watch<AppState>().activeChallengeState;

    return MobileFrame(
      backgroundColor: AppColors.primary,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filled(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/map?nav=${challenge.id}',
                      ),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.green,
                      child: Icon(Icons.check, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.challengeStartedTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.challengeStartedBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.flag_outlined,
                          label: challenge.title,
                          value: l.pointsPts(challenge.points.toString()),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniInfo(
                                label: l.distanceLabel,
                                value: '${challenge.distanceKm} km',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniInfo(
                                label: l.durationLabel,
                                value: challenge.duration,
                              ),
                            ),
                          ],
                        ),
                        if (active != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniInfo(
                                  label: l.stateLabel,
                                  value: _statusLabel(context, active.status),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniInfo(
                                  label: l.startedLabel,
                                  value: _formatStarted(active.startedAt),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7B7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l.challengeStartedTip,
                            style: const TextStyle(
                              color: Colors.brown,
                              fontSize: 12.5,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GradientButton(
                    label: l.startNavigation,
                    icon: Icons.near_me_outlined,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                    foreground: AppColors.primary,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/map?nav=${challenge.id}',
                    ),
                  ),
                  if (showBackToMap) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/map'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: .20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(l.backToMap),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatStarted(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  static String _statusLabel(
    BuildContext context,
    ActiveChallengeStatus status,
  ) {
    final l = AppLocalizations.of(context);
    return switch (status) {
      ActiveChallengeStatus.active => status.name,
      ActiveChallengeStatus.completed => l.challengeStateCompleted,
      ActiveChallengeStatus.abandoned => status.name,
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h3,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    ],
  );
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}
