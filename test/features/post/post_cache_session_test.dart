import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/analytics/analytics_service.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:loop/src/features/auth/domain/usecases/login_with_kakao_usecase.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class AuthFake implements AbstractAuthRepository {
  final events = <String>[];
  bool failLogin = false;
  @override
  Future<void> logout() async {
    events.add('tokens-deleted');
  }

  @override
  Future<Either<Failure, UserModel>> login(LoginRequestModel request) async {
    if (failLogin) return const Left(ServerFailure('invalid login', 401));
    events.add('tokens-saved');
    return Right(
      UserModel(
        id: 2,
        nickname: 'user',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class AnalyticsFake implements AnalyticsService {
  @override
  Future<void> logLogin({required String method}) async {}
  @override
  Future<void> setUserId(int? id) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class GoogleFake implements LoginWithGoogleUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class KakaoFake implements LoginWithKakaoUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthFake auth;
  late LoginStateNotifier notifier;
  setUp(() {
    auth = AuthFake();
    notifier = LoginStateNotifier(
      auth,
      const FlutterSecureStorage(),
      KakaoFake(),
      GoogleFake(),
      AnalyticsFake(),
      onSessionChanged: () async {
        auth.events.add('cache-cleared');
      },
    );
  });
  tearDown(() {
    notifier.dispose();
  });
  test('logout clears cache after tokens have been removed', () async {
    await notifier.logout();
    expect(auth.events, ['tokens-deleted', 'cache-cleared']);
    expect(notifier.state, const LoginState.initial());
  });
  test(
    'successful login clears previous cache before exposing success',
    () async {
      notifier.addListener((state) {
        if (state is LoginSuccess) auth.events.add('success');
      }, fireImmediately: false);
      await notifier.login(email: 'test@example.com', password: 'test');
      expect(auth.events, ['tokens-saved', 'cache-cleared', 'success']);
    },
  );
  test('failed login does not clear existing cache', () async {
    auth.failLogin = true;
    await notifier.login(email: 'test@example.com', password: 'test');
    expect(auth.events, isEmpty);
    expect(notifier.state, isA<LoginError>());
  });
}
