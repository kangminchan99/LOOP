import 'package:flutter/material.dart';

/// 앱 전체 페이지에서 공통으로 사용하는 기본 레이아웃 위젯.
///
/// - [appBarTitle]이 `null`이면 AppBar 없이 렌더링합니다.
/// - [appBarTitle]이 있으면 [AppBar]를 표시하며 SafeArea는 AppBar가 처리합니다.
/// - [backgroundColor]를 생략하면 현재 테마의 [ThemeData.scaffoldBackgroundColor]를 사용합니다.
///
/// 사용 예:
/// ```dart
/// // AppBar 없이
/// DefaultLayout(child: MyContent())
///
/// // AppBar 포함
/// DefaultLayout(appBarTitle: '페이지 제목', child: MyContent())
///
/// // 전체 옵션
/// DefaultLayout(
///   appBarTitle: '제목',
///   centerTitle: false,
///   actions: [IconButton(...)],
///   bottomNavigationBar: MyBottomNav(),
///   child: MyContent(),
/// )
/// ```
class DefaultLayout extends StatelessWidget {
  /// 페이지 본문 위젯 (필수)
  final Widget child;

  /// Scaffold 배경색. 생략 시 테마 기본값 사용
  final Color? backgroundColor;

  /// AppBar 제목 문자열. null이면 AppBar를 렌더링하지 않음
  final String? appBarTitle;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// AppBar 제목 가운데 정렬 여부 (기본값: true)
  final bool centerTitle;

  /// AppBar 좌측 leading 위젯 (기본값: 뒤로가기 버튼 자동 표시)
  final Widget? leading;

  /// AppBar 우측 액션 위젯 목록
  final List<Widget>? actions;

  /// AppBar 그림자 높이
  final double? elevation;

  /// AppBar 하단에 표시할 위젯 (예: TabBar, 구분선)
  final PreferredSizeWidget? bottom;

  /// AppBar flexibleSpace (그래디언트 등을 적용할 때 사용)
  final Widget? flexibleSpace;

  const DefaultLayout({
    super.key,
    required this.child,
    this.backgroundColor,
    this.appBarTitle,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.elevation,
    this.bottom,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: _renderAppBar(theme),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  AppBar? _renderAppBar(ThemeData theme) {
    if (appBarTitle == null) return null;

    return AppBar(
      title: Text(appBarTitle!, style: theme.textTheme.titleLarge),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      elevation: elevation,
      bottom: bottom,
      backgroundColor: flexibleSpace != null ? Colors.transparent : null,
      flexibleSpace: flexibleSpace,
    );
  }
}
