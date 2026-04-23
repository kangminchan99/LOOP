import 'package:flutter/material.dart';
import 'package:loop/src/core/styles/app_theme.dart';
import 'package:loop/src/features/auth/presentation/pages/auth_page.dart';

void main() {
  runApp(const LoopApp());
}

class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loop',
      theme: lightAppTheme,
      home: const AuthPage(),
    );
  }
}
