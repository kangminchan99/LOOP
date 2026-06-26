import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDataSource {
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (serverClientId == null || serverClientId.isEmpty) {
      throw Exception('Google Web Client ID is not set');
    }

    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);

    _initialized = true;
  }

  Future<String> login() async {
    await _initialize();

    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );

    final idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to retrieve Google ID token');
    }

    return idToken;
  }

  Future<void> logout() async {
    await _initialize();
    await GoogleSignIn.instance.signOut();
  }
}
