import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/loop_app_shell.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/pages/login_page.dart';
import 'package:loop/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:loop/src/features/comments/presentation/pages/comment_list_page.dart';
import 'package:loop/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:loop/src/features/post/presentation/pages/board_detail_page.dart';
import 'package:loop/src/features/post/presentation/pages/board_edit_page.dart';
import 'package:loop/src/features/post/presentation/pages/board_page.dart';
import 'package:loop/src/features/post/presentation/pages/board_write_page.dart';
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
      GoRoute(
        path: AppRoute.write.path,
        name: AppRoute.write.name,
        builder: (context, state) => const BoardWritePage(),
      ),
      GoRoute(
        path: AppRoute.notifications.path,
        name: AppRoute.notifications.name,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoute.postDetail.path,
        name: AppRoute.postDetail.name,
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['postId']!);
          return BoardDetailPage(postId: postId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoute.postEdit.name,
            builder: (context, state) {
              final postId = int.parse(state.pathParameters['postId']!);
              return BoardEditPage(postId: postId);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoute.commentList.path,
        name: AppRoute.commentList.name,
        builder: (context, state) {
          return CommentListPage();
        },
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
            navigatorKey: boardBranchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.board.path,
                builder: (context, state) => const BoardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingsBranchNavigatorKey,
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
