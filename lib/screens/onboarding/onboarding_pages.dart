import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 95, 32, 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 96,
            backgroundColor: Colors.white12,
            child: CircleAvatar(
              radius: 64,
              backgroundColor: Colors.white12,
              child: Icon(
                Icons.explore_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: .9),
              ),
            ),
          ),
          const SizedBox(height: 78),
          Text(
            l.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: 20),
          Text(
            l.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.search, l.onboardingStepDiscover, l.onboardingStepDiscoverBody),
      (Icons.navigation_outlined, l.onboardingStepGo, l.onboardingStepGoBody),
      (
        Icons.check_circle_outline,
        l.onboardingStepComplete,
        l.onboardingStepCompleteBody,
      ),
      (
        Icons.card_giftcard,
        l.onboardingStepRewards,
        l.onboardingStepRewardsBody,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 102, 32, 24),
      child: Column(
        children: [
          Text(l.onboardingHowItWorksTitle, style: AppTextStyles.h1),
          const SizedBox(height: 10),
          Text(
            l.onboardingHowItWorksBody,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 54),
          ...steps.indexed.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white12,
                    child: Icon(e.$2.$1, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.$2.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.$2.$3,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .65),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white12,
                    child: Text(
                      '${e.$1 + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionsPage extends StatelessWidget {
  const PermissionsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 24),
      child: Column(
        children: [
          Text(
            l.onboardingPermissionsTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: 16),
          Text(
            l.onboardingPermissionsBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 28),
          PermissionTile(
            icon: Icons.location_on_outlined,
            title: l.locationAccess,
            body: l.onboardingLocationAccessBody,
          ),
          const SizedBox(height: 22),
          PermissionTile(
            icon: Icons.photo_camera_outlined,
            title: l.cameraAccess,
            body: l.onboardingCameraAccessBody,
          ),
          const SizedBox(height: 22),
          PermissionTile(
            icon: Icons.notifications_outlined,
            title: l.notifications,
            body: l.onboardingNotificationsAccessBody,
          ),
          const SizedBox(height: 24),
          Text(
            l.onboardingPrivacyNote,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: .55)),
          ),
        ],
      ),
    );
  }
}

class ReadyToExplorePage extends StatelessWidget {
  const ReadyToExplorePage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 68, 32, 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Image.asset(
                  'assets/Image-Discover-Rila-Monastery@2x.png',
                  height: 258,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .24),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 46),
          Text(
            l.onboardingReadyTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontSize: 34, height: 1.16),
          ),
          const SizedBox(height: 22),
          Text(
            l.onboardingReadyBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              fontSize: 18,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class PermissionTile extends StatelessWidget {
  const PermissionTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white12,
          child: Icon(icon, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .68),
            height: 1.55,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
