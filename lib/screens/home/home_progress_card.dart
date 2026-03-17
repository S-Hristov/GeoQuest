import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final total = app.challenges.length;
    final completed = app.currentUser.completed;
    final remaining = (total - completed).clamp(0, total);
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.yourProgress, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ProgressStatText('$completed', l.completed)),
              Expanded(child: ProgressStatText('$remaining', l.remaining)),
              Expanded(child: ProgressStatText('$percent%', l.completeWord)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressStatText extends StatelessWidget {
  const ProgressStatText(this.value, this.label, {super.key});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 24)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}
