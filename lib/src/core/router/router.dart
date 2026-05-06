import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/loop_app_shell.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/pages/login_page.dart';
import 'package:loop/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:loop/src/features/board/presentation/pages/board_page.dart';
import 'package:loop/src/features/settings/presentation/pages/setting_page.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoute.board.path,
    routes: [
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.signUp.path,
        name: AppRoute.signUp.name,
        builder: (context, state) => const SignUpPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return LoopAppShell(
            currentPageIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.board.path,
                builder: (context, state) => const BoardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings.path,
                builder: (context, state) => const SettingPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
