enum AppRoute { login, signUp, board, settings, write, postDetail, postEdit }

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
      case AppRoute.postDetail:
        return '/posts/:postId';
      case AppRoute.postEdit:
        return '/posts/:postId/edit';
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
      case AppRoute.postDetail:
        return 'postDetail';
      case AppRoute.postEdit:
        return 'postEdit';
    }
  }
}
