class SettingItem {
  final String icon;
  final String label;
  final String value;
  final Function()? onTap;

  SettingItem({
    required this.icon,
    required this.label,
    this.value = '',
    this.onTap,
  });
}

class SettingSection {
  final String title;
  final List<SettingItem> items;

  SettingSection({required this.title, required this.items});
}
