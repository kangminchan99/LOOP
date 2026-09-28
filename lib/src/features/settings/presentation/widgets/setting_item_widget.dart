import 'package:flutter/material.dart';

// 표시와 클릭 전달만 담당한다. 긴 번역/확대 글씨는 subtitle로 줄바꿈한다.
class SettingItemWidget extends StatelessWidget {
  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showDivider = true,
  });
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          enabled: onTap != null,
          leading: Icon(icon),
          title: Text(label),
          subtitle: value == null ? null : Text(value!),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
