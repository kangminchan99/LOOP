import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminWebViewPage extends StatefulWidget {
  const AdminWebViewPage({super.key});

  @override
  State<AdminWebViewPage> createState() => _AdminWebViewPageState();
}

class _AdminWebViewPageState extends State<AdminWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static final Uri _adminUrl = Uri.parse('http://10.0.2.2:3001');

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          // 웹에서 Flutter로 메시지를 보낼 수 있는 통로
          ..addJavaScriptChannel(
            'LoopAdmin',
            onMessageReceived: (message) {
              debugPrint('Admin WebView JS message: ${message.message}');
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (!mounted) return;

                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (_) async {
                if (!mounted) return;

                await _injectSessionTimerFallback();

                if (!mounted) return;

                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (error) {
                debugPrint('Admin WebView error: ${error.description}');
              },
            ),
          );
    _loadAdminPage();
  }

  Future<void> _loadAdminPage() async {
    final accessToken = await _secureStorage.read(key: kAccessTokenKey);
    final refreshToken = await _secureStorage.read(key: kRefreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    await _cookieManager.clearCookies();
    await _controller.clearCache();
    await _controller.clearLocalStorage();

    await _cookieManager.setCookie(
      WebViewCookie(
        name: 'accessToken',
        value: accessToken,
        domain: _adminUrl.host,
        path: '/',
      ),
    );

    await _cookieManager.setCookie(
      WebViewCookie(
        name: 'refreshToken',
        value: refreshToken,
        domain: _adminUrl.host,
        path: '/',
      ),
    );

    final accessTokenExpiresAt =
        DateTime.now()
            .add(const Duration(minutes: 15))
            .millisecondsSinceEpoch
            .toString();

    await _cookieManager.setCookie(
      WebViewCookie(
        name: 'accessTokenExpiresAt',
        value: accessTokenExpiresAt,
        domain: _adminUrl.host,
        path: '/',
      ),
    );

    await _controller.loadRequest(
      _adminUrl.replace(
        queryParameters: {
          ..._adminUrl.queryParameters,
          'webviewTs': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      ),
    );
  }

  Future<void> _injectSessionTimerFallback() async {
    await _controller.runJavaScript('''
      (() => {
        if (window.__loopAdminSessionTimerInterval) {
          window.clearInterval(window.__loopAdminSessionTimerInterval);
        }

        function getCookieValue(name) {
          const cookies = document.cookie
            .split(';')
            .map((cookie) => cookie.trim())
            .filter(Boolean);

          const targetCookie = cookies.find((cookie) =>
            cookie.startsWith(name + '=')
          );

          if (!targetCookie) {
            return null;
          }

          return decodeURIComponent(targetCookie.substring(name.length + 1));
        }

        function formatRemainingTime(milliseconds) {
          const totalSeconds = Math.max(0, Math.floor(milliseconds / 1000));
          const minutes = Math.floor(totalSeconds / 60);
          const seconds = totalSeconds % 60;

          return minutes + ':' + String(seconds).padStart(2, '0');
        }

        function updateSessionTimer() {
          const element = document.getElementById('session-timer-value');

          if (!element) {
            return;
          }

          const expiresAtValue = getCookieValue('accessTokenExpiresAt');
          const expiresAtTime = Number(
            window.__loopAdminAccessTokenExpiresAt || expiresAtValue
          );
          const remainingMilliseconds = Number.isFinite(expiresAtTime)
            ? Math.max(0, expiresAtTime - Date.now())
            : 0;

          element.textContent = formatRemainingTime(remainingMilliseconds);

          if (remainingMilliseconds <= 0) {
            window.location.href = '/login';
          }
        }

        function bindRefreshButton() {
          const button = document.getElementById('session-refresh-button');

          if (!button) {
            return;
          }

          button.onclick = async (event) => {
            event.preventDefault();

            if (button.disabled) {
              return;
            }

            button.disabled = true;
            button.textContent = '연장 중...';

            try {
              const response = await fetch('/api/auth/refresh', {
                method: 'POST',
              });

              if (!response.ok) {
                throw new Error('refresh failed');
              }

              const data = await response.json();

              if (data.accessTokenExpiresAt) {
                window.__loopAdminAccessTokenExpiresAt =
                  data.accessTokenExpiresAt;
              }

              updateSessionTimer();
            } catch (error) {
              window.location.href = '/login';
            } finally {
              button.disabled = false;
              button.textContent = '로그인 연장';
            }
          };
        }

        updateSessionTimer();
        bindRefreshButton();
        window.__loopAdminSessionTimerInterval = window.setInterval(
          updateSessionTimer,
          1000
        );
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 모드')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
