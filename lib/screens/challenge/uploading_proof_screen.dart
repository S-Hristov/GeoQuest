import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class UploadingProofScreen extends StatefulWidget {
  const UploadingProofScreen({
    super.key,
    required this.challenge,
    this.proofPath,
  });
  final Challenge challenge;
  final String? proofPath;
  @override
  State<UploadingProofScreen> createState() => _UploadingProofScreenState();
}

class _UploadingProofScreenState extends State<UploadingProofScreen> {
  double value = .1;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 350), (t) {
      setState(() => value += .18);
      if (value >= 1) {
        t.cancel();
        _completeAndOpenResult();
      }
    });
  }

  Future<void> _completeAndOpenResult() async {
    final state = context.read<AppState>();
    final prevLevel = state.currentUser.level;
    final prevPoints = state.currentUser.points;
    final awarded = await state.completeChallengeAndAward(
      challengeId: widget.challenge.id,
      proofPath: widget.proofPath,
    );
    if (!mounted) return;
    if (!awarded) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settingsSyncFailed)));
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      '/challenge-complete/${widget.challenge.id}?prevLevel=$prevLevel&prevPoints=$prevPoints',
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MobileFrame(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary2),
                const SizedBox(height: 28),
                Text(l.uploadingProofTitle, style: AppTextStyles.h2),
                const SizedBox(height: 10),
                Text(
                  l.uploadingProofBody,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                LinearProgressIndicator(value: value, color: AppColors.magenta),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
