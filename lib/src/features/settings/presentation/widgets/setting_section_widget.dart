import 'package:flutter/material.dart';
import 'package:loop/src/core/styles/app_colors.dart';
import 'package:loop/src/features/settings/data/models/setting_model.dart';

import 'setting_item_widget.dart';

class SettingSectionWidget extends StatelessWidget {
  final SettingSection section;

  const SettingSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(section.items.length, (index) {
              final item = section.items[index];
              final isLast = index == section.items.length - 1;
              return SettingItemWidget(
                icon: item.icon,
                label: item.label,
                value: item.value.isNotEmpty ? item.value : null,
                onTap: item.onTap,
                showDivider: !isLast,
              );
            }),
          ),
        ),
      ],
    );
  }
}
