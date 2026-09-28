import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';
import 'package:loop/src/features/settings/presentation/providers/settings_actions_notifier.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class FakeSettingsRepository implements AbstractSettingRepository {
  int calls = 0;
  Future<Either<Failure, UserModel>> Function(UserModel)? handler;
  @override
  Future<Either<Failure, UserModel>> updateProfile(
    ProfileRequestModel request,
    UserModel user,
  ) {
    calls++;
    return handler?.call(user) ??
        Future.value(Right(user.copyWith(profileImageUrl: 'new-image')));
  }
}

void main() {
  late UserModel? user;
  late int revision;
  late FakeSettingsRepository repository;
  late int applied;
  late int loggedOut;
  UserModel sample() => UserModel(
    id: 1,
    nickname: 'test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  setUp(() {
    user = sample();
    revision = 0;
    repository = FakeSettingsRepository();
    applied = 0;
    loggedOut = 0;
  });
  SettingsActionsNotifier create({
    Future<String?> Function()? picker,
    Future<bool> Function()? unregister,
  }) {
    final notifier = SettingsActionsNotifier(
      pickImage: picker ?? () async => 'image.jpg',
      repository: repository,
      currentUser: () => user,
      sessionRevision: () => revision,
      applyUser: (updated) async {
        applied++;
        user = updated;
      },
      unregisterDevice: unregister ?? () async => true,
      logout: () async {
        loggedOut++;
        user = null;
        revision++;
      },
    );
    addTearDown(() {
      if (notifier.mounted) notifier.dispose();
    });
    return notifier;
  }

  test('선택 취소는 서버를 호출하지 않는다', () async {
    final result = await create(picker: () async => null).updateProfile();
    expect(result, SettingsActionResult.cancelled);
    expect(repository.calls, 0);
  });
  test('사진 선택 중 중복 실행과 로그아웃을 막는다', () async {
    final gate = Completer<String?>();
    final notifier = create(picker: () => gate.future);
    final pending = notifier.updateProfile();
    expect(await notifier.updateProfile(), SettingsActionResult.ignored);
    expect(await notifier.logout(), SettingsActionResult.ignored);
    gate.complete('image.jpg');
    expect(await pending, SettingsActionResult.success);
    expect(repository.calls, 1);
  });
  test('동일 계정 재로그인도 이전 요청 응답을 무시한다', () async {
    final gate = Completer<Either<Failure, UserModel>>();
    repository.handler = (_) => gate.future;
    final notifier = create();
    final pending = notifier.updateProfile();
    await Future<void>.delayed(Duration.zero);
    revision++;
    gate.complete(Right(sample().copyWith(profileImageUrl: 'stale')));
    expect(await pending, SettingsActionResult.ignored);
    expect(applied, 0);
  });
  test('사진 응답이 요청 중 변경된 포인트를 덮지 않는다', () async {
    final gate = Completer<Either<Failure, UserModel>>();
    repository.handler = (_) => gate.future;
    final notifier = create();
    final pending = notifier.updateProfile();
    await Future<void>.delayed(Duration.zero);
    user = user!.copyWith(point: 50);
    gate.complete(Right(sample().copyWith(profileImageUrl: 'new')));
    expect(await pending, SettingsActionResult.success);
    expect(user!.point, 50);
    expect(user!.profileImageUrl, 'new');
  });
  test('선택 중 dispose되면 API를 호출하지 않는다', () async {
    final gate = Completer<String?>();
    final notifier = create(picker: () => gate.future);
    final pending = notifier.updateProfile();
    notifier.dispose();
    gate.complete('image.jpg');
    expect(await pending, SettingsActionResult.ignored);
    expect(repository.calls, 0);
  });
  test('업로드 실패 후에도 다음 작업을 할 수 있다', () async {
    repository.handler = (_) async => const Left(NetworkFailure('test'));
    final notifier = create();
    expect(await notifier.updateProfile(), SettingsActionResult.failed);
    expect(notifier.state, SettingsOperation.idle);
  });
  test('FCM 해제 실패는 로그아웃을 막지 않고 경고 결과로 구분한다', () async {
    final notifier = create(
      unregister: () async => throw StateError('network'),
    );
    expect(await notifier.logout(), SettingsActionResult.logoutWithWarning);
    expect(loggedOut, 1);
  });
  test('FCM 해제 중 계정 변경 시 새 계정을 로그아웃시키지 않는다', () async {
    final gate = Completer<bool>();
    final notifier = create(unregister: () => gate.future);
    final pending = notifier.logout();
    user = sample().copyWith(id: 2);
    revision++;
    gate.complete(true);
    expect(await pending, SettingsActionResult.ignored);
    expect(loggedOut, 0);
  });
}
