import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('게시판 페이지', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
