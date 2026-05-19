import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';

class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginProvider) is LoginSuccess;
    return DefaultLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: () => isLoggedIn
            ? context.push(AppRoute.write.path)
            : ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인 후 글 작성이 가능합니다.')),
              ),
        child: const Icon(Icons.edit),
      ),
      child: Center(
        child: Text(
          '게시판 페이지',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
