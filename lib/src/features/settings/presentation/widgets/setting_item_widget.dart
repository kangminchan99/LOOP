import 'package:flutter/material.dart';

class SettingItemWidget extends StatelessWidget {
  final String icon;
  final String label;
  final String? value;
  final Function()? onTap;
  final bool showDivider;

  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (value != null && value!.isNotEmpty)
                  Text(
                    value!,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                if (value != null && value!.isNotEmpty)
                  const SizedBox(width: 8),
                Text(
                  '›',
                  style: TextStyle(fontSize: 20, color: theme.dividerColor),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.dividerColor,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
