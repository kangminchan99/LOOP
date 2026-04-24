enum AppRoute { auth }

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.auth:
        return '/';
    }
  }

  String get name {
    switch (this) {
      case AppRoute.auth:
        return 'auth';
    }
  }
}
