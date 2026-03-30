import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_permission_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.permissionService = const DevicePermissionService(),
  });

  final AppPermissionService permissionService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loadingPermissions = true;
  bool _locationGranted = false;
  bool _cameraGranted = false;
  bool _notificationsGranted = false;

  @override
  void initState() {
    super.initState();
    _syncPermissionRows();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MobileFrame(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settings),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: BackButton(onPressed: () => Navigator.maybePop(context)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Group(
              title: l.preferences,
              children: [
                _Row(
                  icon: Icons.language,
                  title: l.language,
                  sub: context.watch<AppState>().locale.languageCode == 'bg'
                      ? l.bulgarian
                      : l.english,
                  onTap: _showLanguage,
                ),
                _SwitchRow(
                  icon: Icons.dark_mode_outlined,
                  title: l.darkMode,
                  sub: l.darkModeSub,
                  value: context.watch<AppState>().themeMode == ThemeMode.dark,
                  onChanged: (v) => context.read<AppState>().setDarkMode(v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Group(
              title: l.permissions,
              children: [
                _SwitchRow(
                  icon: Icons.location_on_outlined,
                  title: l.locationAccess,
                  sub: l.settingsAllowLocationServices,
                  value: _locationGranted,
                  enabled: !_loadingPermissions,
                  onChanged: (v) =>
                      _onPermissionToggle(AppPermissionType.location, v),
                ),
                _SwitchRow(
                  icon: Icons.photo_camera_outlined,
                  title: l.cameraAccess,
                  sub: l.settingsAllowCameraAccess,
                  value: _cameraGranted,
                  enabled: !_loadingPermissions,
                  onChanged: (v) =>
                      _onPermissionToggle(AppPermissionType.camera, v),
                ),
                _SwitchRow(
                  icon: Icons.notifications_outlined,
                  title: l.notifications,
                  sub: l.settingsAllowNotifications,
                  value: _notificationsGranted,
                  enabled: !_loadingPermissions,
                  onChanged: (v) =>
                      _onPermissionToggle(AppPermissionType.notifications, v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Group(
              title: l.account,
              children: [
                _Row(
                  icon: Icons.account_circle_outlined,
                  title: l.editProfile,
                  sub: l.settingsEditProfileSub,
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                _Row(
                  icon: Icons.logout,
                  title: l.settingsSignOut,
                  sub: l.settingsSignOutSub,
                  onTap: () async {
                    await context.read<AppState>().signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/sign-in',
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Group(
              title: l.about,
              children: [
                _Row(
                  icon: Icons.info_outline,
                  title: l.aboutApp,
                  sub: l.settingsVersion('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguage() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).selectLanguage,
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).english),
                trailing: context.watch<AppState>().locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<AppState>().setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).bulgarian),
                trailing: context.watch<AppState>().locale.languageCode == 'bg'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<AppState>().setLocale(const Locale('bg'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncPermissionRows() async {
    if (mounted) {
      setState(() => _loadingPermissions = true);
    }
    final location = await widget.permissionService.status(
      AppPermissionType.location,
    );
    final camera = await widget.permissionService.status(
      AppPermissionType.camera,
    );
    final notifications = await widget.permissionService.status(
      AppPermissionType.notifications,
    );
    if (!mounted) return;

    final app = context.read<AppState>();
    await app.setLocationEnabled(location.granted);
    await app.setCameraEnabled(camera.granted);
    await app.setNotificationsEnabled(notifications.granted);

    setState(() {
      _locationGranted = location.granted;
      _cameraGranted = camera.granted;
      _notificationsGranted = notifications.granted;
      _loadingPermissions = false;
    });
  }

  Future<void> _onPermissionToggle(AppPermissionType type, bool enable) async {
    if (_loadingPermissions) return;
    setState(() => _loadingPermissions = true);

    try {
      AppPermissionState state;
      if (enable) {
        state = await widget.permissionService.request(type);
      } else {
        await widget.permissionService.openSettings();
        state = await widget.permissionService.status(type);
      }

      if (!state.granted && state.permanentlyDenied) {
        await widget.permissionService.openSettings();
      }
    } finally {
      if (mounted) {
        await _syncPermissionRows();
      }
    }
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => PrimaryCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: AppTextStyles.h2),
        ),
        ...children,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.sub,
    this.onTap,
  });
  final IconData icon;
  final String title, sub;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColors.primary.withValues(alpha: .1),
      child: Icon(icon, color: AppColors.primary),
    ),
    title: Text(title),
    subtitle: Text(sub),
    trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });
  final IconData icon;
  final String title, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColors.green.withValues(alpha: .1),
      child: Icon(icon, color: AppColors.green),
    ),
    title: Text(title),
    subtitle: Text(sub),
    trailing: Switch(value: value, onChanged: enabled ? onChanged : null),
  );
}
