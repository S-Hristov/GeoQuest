import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'challenge_list_view.dart';
import 'geo_map_view.dart';
import 'map_filters.dart';
import 'map_sheets.dart';
import 'map_toggle.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.list = false,
    this.navigationChallengeId,
    this.initialCategory,
  });

  final bool list;
  final String? navigationChallengeId;
  final String? initialCategory;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapKey = GlobalKey<GeoMapViewState>();
  late bool list = widget.list;
  late ChallengeFilters filters;

  @override
  void initState() {
    super.initState();
    filters = ChallengeFilters(
      category: widget.initialCategory == null
          ? null
          : normalizeCategory(widget.initialCategory!),
    );
  }

  bool get _navigationMode => widget.navigationChallengeId != null;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final allChallenges = app.challenges.where(filters.matches).toList();
    final navChallenge = widget.navigationChallengeId == null
        ? null
        : app.challengeById(widget.navigationChallengeId!);
    final visibleChallenges = _navigationMode && navChallenge != null
        ? [navChallenge]
        : allChallenges;

    return PopScope(
      canPop: !_navigationMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _navigationMode) {
          Navigator.pushReplacementNamed(context, '/map');
        }
      },
      child: GeoQuestShell(
        selectedTab: GeoQuestTab.map,
        child: Column(
          children: [
            if (_navigationMode && navChallenge != null)
              _NavigationModeHeader(challenge: navChallenge)
            else
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.exploreMap, style: AppTextStyles.title),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search challenges...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: _showFilters,
                            icon: Icon(
                              filters.isEmpty
                                  ? Icons.filter_alt_outlined
                                  : Icons.filter_alt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: MapToggle(
                                label: l.mapView,
                                icon: Icons.map_outlined,
                                selected: !list,
                                onTap: () => setState(() => list = false),
                              ),
                            ),
                            Expanded(
                              child: MapToggle(
                                label: l.listView,
                                icon: Icons.list,
                                selected: list,
                                onTap: () => setState(() => list = true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _navigationMode
                  ? GeoMapView(
                      key: _mapKey,
                      challenges: visibleChallenges,
                      activeChallengeId: app.activeChallengeId,
                      completedChallengeIds: app.completedChallengeIds,
                      onInactiveChallenge: (_) {},
                      onActiveChallenge: (_) {},
                      navigationMode: true,
                    )
                  : list
                  ? ChallengeListView(challenges: visibleChallenges)
                  : GeoMapView(
                      key: _mapKey,
                      challenges: visibleChallenges,
                      activeChallengeId: app.activeChallengeId,
                      completedChallengeIds: app.completedChallengeIds,
                      onInactiveChallenge: _openChallengePreview,
                      onActiveChallenge: _openActiveChallenge,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilters() async {
    final result = await showMapFiltersSheet(context, filters);
    if (result != null && mounted) {
      setState(() => filters = result);
    }
  }

  void _openChallengePreview(Challenge challenge) {
    final app = context.read<AppState>();
    final completed = app.isChallengeCompleted(challenge.id);
    showChallengePreviewSheet(
      context,
      challenge,
      isCompleted: completed,
      onViewCompleted: () =>
          Navigator.pushNamed(context, '/challenge-complete/${challenge.id}'),
      onStart: () async {
        await app.startChallenge(challenge.id);
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/challenge-started/${challenge.id}?from=map',
        );
      },
      onDetails: () =>
          Navigator.pushNamed(context, '/challenge/${challenge.id}'),
    );
  }

  void _openActiveChallenge(Challenge challenge) {
    showActiveChallengeSheet(
      context,
      challenge,
      onDirections: () async {
        await context.read<AppState>().markRouteShown(challenge.id);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/map?nav=${challenge.id}');
      },
    );
  }
}

class _NavigationModeHeader extends StatelessWidget {
  const _NavigationModeHeader({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: PrimaryCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/map'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Navigation Mode', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      challenge.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/challenge/${challenge.id}?from=nav',
                ),
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.completeChallenge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
