import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile(
    this.icon,
    this.title,
    this.sub,
    this.color, {
    super.key,
    this.onTap,
  });

  final String icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PrimaryCard(
    onTap: onTap,
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: .1),
          child: Text(icon),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(sub, style: AppTextStyles.small),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
