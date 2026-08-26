enum AppRoute {
  login,
  signUp,
  board,
  settings,
  write,
  postDetail,
  postEdit,
  notifications,
  commentList,
  bluetooth,
  chatRooms,
  chatRoomDetail,
  adminWebView,
  adminServerStatus,
}

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
      case AppRoute.notifications:
        return '/notifications';
      case AppRoute.commentList:
        return '/comment-list';
      case AppRoute.bluetooth:
        return '/bluetooth';
      case AppRoute.chatRooms:
        return '/chat/rooms';
      case AppRoute.chatRoomDetail:
        return '/chat/rooms/:roomId';
      case AppRoute.adminWebView:
        return '/admin-webview';
      case AppRoute.adminServerStatus:
        return '/admin/server-status';
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
      case AppRoute.notifications:
        return 'notifications';
      case AppRoute.commentList:
        return 'commentList';
      case AppRoute.bluetooth:
        return 'bluetooth';
      case AppRoute.chatRooms:
        return 'chatRooms';
      case AppRoute.chatRoomDetail:
        return 'chatRoomDetail';
      case AppRoute.adminWebView:
        return 'adminWebView';
      case AppRoute.adminServerStatus:
        return 'adminServerStatus';
    }
  }
}
