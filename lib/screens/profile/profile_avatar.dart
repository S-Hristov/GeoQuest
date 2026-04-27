import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.backgroundColor,
    this.textStyle,
  });

  final UserProfile user;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final path = user.avatarPath;
    final isUrl = path != null && path.startsWith('http');
    final isLocal =
        !kIsWeb && path != null && !isUrl && path.isNotEmpty && File(path).existsSync();
    final showImage = isUrl || isLocal;
    ImageProvider? image;
    if (isUrl) image = NetworkImage(path);
    if (isLocal) image = FileImage(File(path));
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      backgroundImage: image,
      child: showImage
          ? null
          : Text(
              user.initials,
              style: textStyle ?? const TextStyle(color: Colors.white),
            ),
    );
  }
}
