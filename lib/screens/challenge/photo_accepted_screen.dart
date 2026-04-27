import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class PhotoAcceptedScreen extends StatefulWidget {
  const PhotoAcceptedScreen({
    super.key,
    required this.challenge,
    this.proofPath,
  });
  final Challenge challenge;
  final String? proofPath;

  @override
  State<PhotoAcceptedScreen> createState() => _PhotoAcceptedScreenState();
}

class _PhotoAcceptedScreenState extends State<PhotoAcceptedScreen> {
  bool _awarding = true;
  int _prevLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _award());
  }

  Future<void> _award() async {
    _prevLevel = context.read<AppState>().currentUser.level;
    await context.read<AppState>().completeChallengeAndAward(
      challengeId: widget.challenge.id,
      proofPath: widget.proofPath,
    );
    if (!mounted) return;
    setState(() => _awarding = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MobileFrame(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 94,
                ),
                const SizedBox(height: 28),
                Text(
                  l.photoAcceptedTitle,
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l.photoAcceptedBody,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                PrimaryCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: AppColors.primary2,
                      ),
                    ),
                    title: Text(
                      l.firstStepsBadge,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      l.pointsEarned(widget.challenge.points.toString()),
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                GradientButton(
                  label: _awarding ? l.updatingRewards : l.viewRewardDetails,
                  enabled: !_awarding,
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/challenge-complete/${widget.challenge.id}?prevLevel=$_prevLevel',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
