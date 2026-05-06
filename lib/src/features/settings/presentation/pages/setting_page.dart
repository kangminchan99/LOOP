import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('설정 페이지', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
