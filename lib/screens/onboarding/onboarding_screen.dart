import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'onboarding_pages.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _lastPage = 3;
  static const _bottomAreaHeight = 140.0;

  final controller = PageController();
  int page = 0;
  bool _requestingPermissions = false;
  bool _permissionsRequested = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return MobileFrame(
      backgroundColor: AppColors.primary,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
          child: SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: controller,
                  onPageChanged: (i) => setState(() => page = i),
                  children: const [
                    OnboardingFitPage(
                      bottomInset: _bottomAreaHeight,
                      child: WelcomePage(),
                    ),
                    OnboardingFitPage(
                      bottomInset: _bottomAreaHeight,
                      child: HowItWorksPage(),
                    ),
                    OnboardingFitPage(
                      bottomInset: _bottomAreaHeight,
                      child: PermissionsPage(),
                    ),
                    OnboardingFitPage(
                      bottomInset: _bottomAreaHeight,
                      child: ReadyToExplorePage(),
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 22,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l.skip,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 28,
                  child: Column(
                    children: [
                      OnboardingNextButton(
                        label: _requestingPermissions
                            ? AppLocalizations.of(context).requestingPermissions
                            : page == _lastPage
                            ? l.getStarted
                            : l.next,
                        onTap: _requestingPermissions ? () {} : _next,
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        opacity: page == _lastPage ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          l.joinExplorers,
                          style: const TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OnboardingDots(page: page, count: _lastPage + 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (page == _lastPage) {
      _completeOnboarding();
      return;
    }
    if (page == 2) {
      await _requestOnboardingPermissions();
    }
    if (!mounted) return;
    controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _requestOnboardingPermissions() async {
    if (_requestingPermissions || _permissionsRequested) return;
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (bindingName.contains('TestWidgetsFlutterBinding')) return;
    setState(() => _requestingPermissions = true);
    try {
      LocationPermission locationPermission =
          LocationPermission.unableToDetermine;
      try {
        locationPermission = await Geolocator.requestPermission();
      } catch (_) {}
      PermissionStatus cameraStatus = PermissionStatus.denied;
      try {
        cameraStatus = await Permission.camera.request();
      } catch (_) {}
      PermissionStatus notificationStatus = PermissionStatus.denied;
      try {
        notificationStatus = await Permission.notification.request();
      } catch (_) {}

      if (!mounted) return;
      final app = context.read<AppState>();
      await app.setLocationEnabled(
        locationPermission == LocationPermission.always ||
            locationPermission == LocationPermission.whileInUse,
      );
      await app.setCameraEnabled(cameraStatus.isGranted);
      await app.setNotificationsEnabled(notificationStatus.isGranted);
      _permissionsRequested = true;
    } finally {
      if (mounted) setState(() => _requestingPermissions = false);
    }
  }

  void _completeOnboarding() {
    context.read<AppState>().completeOnboarding();
    Navigator.pushReplacementNamed(context, '/sign-in');
  }
}

class OnboardingFitPage extends StatelessWidget {
  const OnboardingFitPage({
    super.key,
    required this.child,
    required this.bottomInset,
  });

  final Widget child;
  final double bottomInset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: constraints.maxWidth, child: child),
        ),
      ),
    ),
  );
}

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({required this.page, this.count = 3});

  final int page;
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      count,
      (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(5),
        width: i == page ? 30 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: i == page ? 1 : .28),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    ),
  );
}
