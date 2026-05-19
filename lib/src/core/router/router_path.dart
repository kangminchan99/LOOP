enum AppRoute { login, signUp, board, settings, write }

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.login:
        return '/';
      case AppRoute.signUp:
        return '/sign-up';
      case AppRoute.board:
        return '/board';
      case AppRoute.write:
        return '/write';
      case AppRoute.settings:
        return '/settings';
    }
  }

  String get name {
    switch (this) {
      case AppRoute.login:
        return 'login';
      case AppRoute.signUp:
        return 'signUp';
      case AppRoute.board:
        return 'board';
      case AppRoute.write:
        return 'write';
      case AppRoute.settings:
        return 'settings';
    }
  }
}
