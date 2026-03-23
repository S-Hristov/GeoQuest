import 'package:flutter/material.dart';

import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'map_filters.dart';

void showChallengePreviewSheet(
  BuildContext context,
  Challenge challenge, {
  required VoidCallback onStart,
  required VoidCallback onDetails,
  bool isCompleted = false,
  VoidCallback? onViewCompleted,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    builder: (context) => _ChallengePreviewSheet(
      challenge: challenge,
      onStart: onStart,
      onDetails: onDetails,
      isCompleted: isCompleted,
      onViewCompleted: onViewCompleted,
    ),
  );
}

void showActiveChallengeSheet(
  BuildContext context,
  Challenge challenge, {
  required VoidCallback onDirections,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    builder: (context) =>
        _ActiveChallengeSheet(challenge: challenge, onDirections: onDirections),
  );
}

Future<ChallengeFilters?> showMapFiltersSheet(
  BuildContext context,
  ChallengeFilters current,
) {
  final colorScheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<ChallengeFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    builder: (context) => _MapFiltersSheet(initial: current),
  );
}

class _ChallengePreviewSheet extends StatelessWidget {
  const _ChallengePreviewSheet({
    required this.challenge,
    required this.onStart,
    required this.onDetails,
    this.isCompleted = false,
    this.onViewCompleted,
  });

  final Challenge challenge;
  final VoidCallback onStart;
  final VoidCallback onDetails;
  final bool isCompleted;
  final VoidCallback? onViewCompleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(challenge.title, style: AppTextStyles.h2)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                challenge.imageAsset,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              challenge.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                StatusChip(
                  text: difficultyLabel(context, challenge.difficulty),
                  color: difficultyColor(challenge.difficulty),
                ),
                const SizedBox(width: 8),
                Text(
                  challenge.category,
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '+${challenge.points} pts',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: isCompleted
                  ? 'View Completed Challenge'
                  : 'Start Challenge',
              gradient: isCompleted
                  ? AppColors.actionGradient
                  : AppColors.purpleGradient,
              onPressed: () {
                Navigator.pop(context);
                if (isCompleted) {
                  (onViewCompleted ?? onDetails)();
                  return;
                }
                onStart();
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onDetails();
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              child: const Text('Challenge Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChallengeSheet extends StatelessWidget {
  const _ActiveChallengeSheet({
    required this.challenge,
    required this.onDirections,
  });

  final Challenge challenge;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.navigation_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(challenge.title, style: AppTextStyles.h2)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Active challenge. Open directions when you are ready to navigate.',
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Directions',
              icon: Icons.near_me_outlined,
              gradient: AppColors.purpleGradient,
              onPressed: () {
                Navigator.pop(context);
                onDirections();
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/challenge/${challenge.id}'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              child: const Text('Challenge Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFiltersSheet extends StatefulWidget {
  const _MapFiltersSheet({required this.initial});

  final ChallengeFilters initial;

  @override
  State<_MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<_MapFiltersSheet> {
  late ChallengeFilters filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      minChildSize: .35,
      maxChildSize: .92,
      builder: (context, controller) => Material(
        color: colorScheme.surface,
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filters',
                    style: AppTextStyles.h2.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ChoiceSection<Difficulty>(
              title: 'Difficulty',
              values: Difficulty.values,
              selected: filters.difficulty,
              label: (value) => difficultyLabel(context, value),
              onSelected: (value) => setState(
                () => filters = filters.copyWith(
                  difficulty: value,
                  clearDifficulty: filters.difficulty == value,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ChoiceSection<String>(
              title: 'Category',
              values: const ['Cultural', 'Nature', 'Adventure', 'Historical'],
              selected: filters.category,
              label: (value) => value,
              onSelected: (value) => setState(
                () => filters = filters.copyWith(
                  category: value,
                  clearCategory: filters.category == value,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ChoiceSection<double>(
              title: 'Max Distance',
              values: const [1, 5, 10, 25],
              selected: filters.maxDistanceKm,
              label: (value) => '${value.toStringAsFixed(0)} km',
              onSelected: (value) => setState(
                () => filters = filters.copyWith(
                  maxDistanceKm: value,
                  clearDistance: filters.maxDistanceKm == value,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const ChallengeFilters()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, filters),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T? selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: values
              .map(
                (value) => ChoiceChip(
                  label: Text(label(value)),
                  selected: value == selected,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: value == selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  side: BorderSide(
                    color: value == selected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  onSelected: (_) => onSelected(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
