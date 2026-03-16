import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../services/location_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    this.initialStatus = ChallengeStatus.ready,
    this.fromNavigation = false,
  });
  final Challenge challenge;
  final ChallengeStatus initialStatus;
  final bool fromNavigation;

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late ChallengeStatus status = widget.initialStatus;
  double? distance;
  bool checking = false;

  Future<void> _attemptComplete() async {
    if (checking) return;
    setState(() => checking = true);
    final l = AppLocalizations.of(context);
    final result = await const LocationService().checkChallenge(
      widget.challenge,
    );
    if (!mounted) return;
    setState(() {
      status = result.status;
      distance = result.distanceMeters;
      checking = false;
    });

    if (result.status == ChallengeStatus.locationReached) {
      Navigator.pushNamed(context, '/camera-proof/${widget.challenge.id}');
      return;
    }

    final distanceLabel = result.distanceMeters == null
        ? '0.5 km'
        : '${(result.distanceMeters! / 1000).toStringAsFixed(1)} km';
    final message = switch (result.status) {
      ChallengeStatus.locationPermissionRequired =>
        l.locationPermissionRequiredBody,
      ChallengeStatus.tooFar => l.tooFarAwayBody(distanceLabel),
      ChallengeStatus.ready => l.navigateLocationBody,
      ChallengeStatus.locationReached => l.locationReachedBody,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.challenge;
    final app = context.watch<AppState>();
    final isActive = app.isChallengeActive(c.id);
    final isCompleted = app.isChallengeCompleted(c.id);
    final hideNavigate = widget.fromNavigation;

    return MobileFrame(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 228,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(c.imageAsset, fit: BoxFit.cover),
                    Container(color: Colors.black.withValues(alpha: .36)),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton.filled(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusChip(
                                text: difficultyLabel(context, c.difficulty),
                                color: difficultyColor(c.difficulty),
                              ),
                              StatusChip(
                                text: categoryLabel(context, c.category),
                                color: AppColors.primary2,
                              ),
                              if (isActive)
                                StatusChip(
                                  text: l.challengeStateActive,
                                  color: AppColors.primary,
                                ),
                              if (isCompleted)
                                StatusChip(
                                  text: l.challengeStateCompleted,
                                  color: AppColors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h1.copyWith(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CompactStat(
                              icon: Icons.location_on_outlined,
                              value: '${c.distanceKm} km',
                              label: l.awayLabel,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _CompactStat(
                              icon: Icons.emoji_events_outlined,
                              value: '+${c.points}',
                              label: l.pointsLabel,
                              color: AppColors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _CompactStat(
                              icon: Icons.schedule,
                              value: c.duration,
                              label: l.durationLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PrimaryCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.aboutThisChallenge, style: AppTextStyles.h2),
                            const SizedBox(height: 8),
                            Text(
                              c.description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryCard(
                        padding: const EdgeInsets.all(14),
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.primary2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.rewardLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    l.rewardFirstStepsPoints(
                                      c.points.toString(),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.small,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StatusBox(
                        status: isCompleted
                            ? ChallengeStatus.locationReached
                            : status,
                        distance: distance,
                        active: isActive,
                        completed: isCompleted,
                      ),
                      const Spacer(),
                      if (isCompleted)
                        GradientButton(
                          label: l.viewCompletedChallenge,
                          gradient: AppColors.purpleGradient,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/challenge-complete/${c.id}',
                          ),
                        )
                      else if (!isActive)
                        GradientButton(
                          label: l.startChallenge,
                          gradient: AppColors.purpleGradient,
                          onPressed: () async {
                            await context.read<AppState>().startChallenge(c.id);
                            if (!mounted) return;
                            Navigator.pushNamed(
                              context,
                              '/challenge-started/${c.id}',
                            );
                          },
                        )
                      else ...[
                        GradientButton(
                          label: checking
                              ? l.checkingLocation
                              : l.completeChallenge,
                          gradient: AppColors.actionGradient,
                          enabled: !checking,
                          onPressed: _attemptComplete,
                        ),
                        const SizedBox(height: 10),
                        if (!hideNavigate) ...[
                          GradientButton(
                            label: l.navigate,
                            icon: Icons.near_me_outlined,
                            gradient: AppColors.purpleGradient,
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/map?nav=${c.id}',
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => PrimaryCard(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small,
        ),
      ],
    ),
  );
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.status,
    this.distance,
    required this.active,
    required this.completed,
  });

  final ChallengeStatus status;
  final double? distance;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final distanceLabel = distance == null
        ? '0.5 km'
        : '${(distance! / 1000).toStringAsFixed(1)} km';
    if (completed) {
      return _Box(
        color: AppColors.green,
        title: l.challengeCompletedTitle,
        body: l.challengeCompletedBody,
        icon: Icons.check_circle,
      );
    }
    if (!active) {
      return _Box(
        color: AppColors.primary,
        title: l.startFirstTitle,
        body: l.startFirstBody,
        icon: Icons.flag_outlined,
      );
    }
    return switch (status) {
      ChallengeStatus.ready => _Box(
        color: AppColors.orange,
        title: l.navigateLocationTitle,
        body: l.navigateLocationBody,
        icon: Icons.near_me_outlined,
      ),
      ChallengeStatus.locationPermissionRequired => _Box(
        color: AppColors.orange,
        title: l.locationPermissionRequiredTitle,
        body: l.locationPermissionRequiredBody,
        icon: Icons.location_off_outlined,
      ),
      ChallengeStatus.tooFar => _Box(
        color: AppColors.red,
        title: l.tooFarAwayTitle,
        body: l.tooFarAwayBody(distanceLabel),
        icon: Icons.error_outline,
      ),
      ChallengeStatus.locationReached => _Box(
        color: AppColors.green,
        title: l.locationReachedTitle,
        body: l.locationReachedBody,
        icon: Icons.check_circle,
      ),
    };
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.color,
    required this.title,
    required this.body,
    required this.icon,
  });
  final Color color;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      border: Border.all(color: color.withValues(alpha: .25)),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: TextStyle(color: color, height: 1.35, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
