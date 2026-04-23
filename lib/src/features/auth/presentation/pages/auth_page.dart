import 'package:flutter/material.dart';
import 'package:loop/src/core/layout/default_layout.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBarTitle: 'Auth Page',
      child: SafeArea(child: Center(child: Text('Welcome to the Auth Page'))),
    );
  }
}
