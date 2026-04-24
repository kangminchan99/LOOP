import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/pages/auth_page.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoute.auth.path,
    routes: [
      GoRoute(
        path: AppRoute.auth.path,
        name: AppRoute.auth.name,
        builder: (context, state) => AuthPage(),
      ),
    ],
  );
});
