import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  String? _avatarPath;
  bool _saving = false;
  bool _didSeedBio = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController();
    _avatarPath = user.avatarPath;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSeedBio) return;
    _didSeedBio = true;
    final user = context.read<AppState>().currentUser;
    _bioController.text = AppLocalizations.of(
      context,
    ).profileLevelExplorer(user.level.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<AppState>().currentUser;
    return MobileFrame(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.editProfileTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PrimaryCard(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(60),
                    child: Stack(
                      children: [
                        _EditableAvatar(
                          user: user,
                          radius: 50,
                          avatarPath: _avatarPath,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.tapProfilePhoto,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.personalInformation, style: AppTextStyles.h2),
                    const SizedBox(height: 22),
                    Text(l.fullName),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? l.pleaseEnterName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l.emailLabel),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return l.pleaseEnterEmail;
                        final ok = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email);
                        return ok ? null : l.pleaseEnterValidEmail;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(l.bioLabel),
                    TextFormField(controller: _bioController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: _saving ? l.saving : l.saveChanges,
              gradient: AppColors.purpleGradient,
              enabled: !_saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.choosePhoto),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.takePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (!mounted || file == null) return;
    setState(() => _avatarPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<AppState>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      avatarPath: _avatarPath,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saveProfileError)),
      );
      return;
    }
    Navigator.pop(context);
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.user,
    required this.radius,
    required this.avatarPath,
  });

  final UserProfile user;
  final double radius;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final showImage =
        !kIsWeb &&
        avatarPath != null &&
        avatarPath!.isNotEmpty &&
        File(avatarPath!).existsSync();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: showImage ? FileImage(File(avatarPath!)) : null,
      child: showImage
          ? null
          : ProfileAvatar(
              user: user,
              radius: radius,
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(color: Colors.white, fontSize: 30),
            ),
    );
  }
}
