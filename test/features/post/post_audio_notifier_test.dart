import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_recorder_data_source.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_state.dart';

const _clipPath = '/tmp/post_audio_test/clip.m4a';

class _FakeStopwatch extends Stopwatch {
  Duration measured = Duration.zero;

  @override
  Duration get elapsed => measured;

  @override
  void reset() {
    super.reset();
    measured = Duration.zero;
  }
}

class _FakeRecorder implements PostAudioRecorderDataSource {
  bool permissionGranted = true;
  bool failStart = false;
  bool failDiscard = false;
  bool failStop = false;
  String? stoppedPath = _clipPath;
  Completer<bool>? pendingPermission;
  Completer<void>? pathEntered;
  Completer<String>? pendingPath;
  Completer<void>? startEntered;
  Completer<void>? pendingStart;
  Completer<String?>? pendingStop;
  final calls = <String>[];
  final disposed = Completer<void>();

  @override
  Future<bool> requestPermission() async {
    calls.add('permission');
    final pending = pendingPermission;
    return pending == null ? permissionGranted : await pending.future;
  }

  @override
  Future<String> createRecordingPath() async {
    calls.add('createPath');
    pathEntered?.complete();
    final pending = pendingPath;
    return pending == null ? _clipPath : await pending.future;
  }

  @override
  Future<void> start({required String path}) async {
    expect(path, _clipPath);
    calls.add('start');
    if (failStart) throw StateError('Cannot start recording');
    startEntered?.complete();
    final pending = pendingStart;
    if (pending != null) await pending.future;
  }

  @override
  Future<String?> stop() async {
    calls.add('stop');
    if (failStop) throw StateError('Cannot stop recording');
    final pending = pendingStop;
    return pending == null ? stoppedPath : await pending.future;
  }

  @override
  Future<void> discardRecording() async {
    calls.add('discard');
    if (failDiscard) throw StateError('Cannot discard recording');
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    disposed.complete();
  }
}

void main() {
  late _FakeRecorder recorder;
  late _FakeStopwatch stopwatch;
  late PostAudioNotifier notifier;

  setUp(() {
    recorder = _FakeRecorder();
    stopwatch = _FakeStopwatch();
    notifier = PostAudioNotifier(recorder, stopwatch: stopwatch);
  });
  tearDown(() {
    if (notifier.mounted) notifier.dispose();
  });

  testWidgets('준비 시간은 제외하고 녹음 60초에 한 번만 자동 종료한다', (tester) async {
    recorder.startEntered = Completer<void>();
    recorder.pendingStart = Completer<void>();
    final start = notifier.startRecording();
    await recorder.startEntered!.future;
    expect(recorder.calls.last, 'start');

    await tester.pump(const Duration(seconds: 60));
    expect(notifier.state, const PostAudioState.preparing());
    expect(recorder.calls, isNot(contains('stop')));

    recorder.pendingStart!.complete();
    await start;
    expect(
      notifier.state,
      const PostAudioState.recording(elapsed: Duration.zero),
    );

    stopwatch.measured = const Duration(seconds: 59, milliseconds: 300);
    await tester.pump(const Duration(seconds: 59));
    expect(
      notifier.state,
      const PostAudioState.recording(elapsed: Duration(seconds: 59)),
    );
    expect(recorder.calls, isNot(contains('stop')));

    stopwatch.measured = const Duration(seconds: 60);
    await tester.pump(const Duration(seconds: 1));
    expect(notifier.state, const PostAudioState.ready(filePath: _clipPath));
    await tester.pump(const Duration(seconds: 60));
    expect(recorder.calls.where((call) => call == 'stop'), hasLength(1));
    expect(stopwatch.isRunning, isFalse);
  });

  testWidgets('수동 종료와 취소가 이전 녹음의 타이머를 남기지 않는다', (tester) async {
    await notifier.startRecording();
    await tester.pump(const Duration(seconds: 10));
    await notifier.stopRecording();
    await notifier.discardRecording();

    await notifier.startRecording();
    await tester.pump(const Duration(seconds: 50));
    expect(notifier.state, isA<PostAudioRecording>());
    await notifier.discardRecording();
    await tester.pump(const Duration(seconds: 60));

    expect(notifier.state, const PostAudioState.idle());
    expect(recorder.calls.where((call) => call == 'stop'), hasLength(1));
    expect(stopwatch.isRunning, isFalse);
  });

  testWidgets('Notifier가 해제되면 녹음 타이머 콜백을 더 실행하지 않는다', (tester) async {
    await notifier.startRecording();
    notifier.dispose();
    await tester.pump(const Duration(seconds: 60));

    expect(recorder.calls, isNot(contains('stop')));
    expect(stopwatch.isRunning, isFalse);
    expect(recorder.calls.skip(recorder.calls.length - 2), [
      'discard',
      'dispose',
    ]);
  });

  test('화면을 닫으면 진행 중인 녹음 시작이 끝난 뒤 파일과 녹음기를 정리한다', () async {
    recorder.startEntered = Completer<void>();
    recorder.pendingStart = Completer<void>();
    final starting = notifier.startRecording();
    await recorder.startEntered!.future;
    recorder.calls.clear();

    notifier.dispose();
    expect(recorder.calls, isEmpty);

    recorder.pendingStart!.complete();
    await starting;
    await recorder.disposed.future;
    expect(recorder.calls, ['discard', 'dispose']);
    expect(stopwatch.isRunning, isFalse);
  });

  test('녹음 종료를 기다렸다가 화면을 떠난 뒤에는 파일을 폐기한다', () async {
    await notifier.startRecording();
    recorder.pendingStop = Completer<String?>();
    recorder.calls.clear();
    final stopping = notifier.stopRecording();

    notifier.dispose();
    expect(recorder.calls, ['stop']);

    recorder.pendingStop!.complete(_clipPath);
    await stopping;
    await recorder.disposed.future;
    expect(recorder.calls, ['stop', 'discard', 'dispose']);
  });

  test('임시 파일 정리에 실패해도 녹음기 해제를 시도한다', () async {
    await notifier.startRecording();
    recorder.failDiscard = true;
    recorder.calls.clear();

    notifier.dispose();
    await recorder.disposed.future;

    expect(recorder.calls, ['discard', 'dispose']);
  });

  test('글쓰기 키마다 Notifier가 분리되고 마지막 구독 해제 후 정리된다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final first = postAudioProvider(Object());
    final second = postAudioProvider(Object());
    final firstSubscription = container.listen(first, (_, _) {});
    final secondSubscription = container.listen(second, (_, _) {});
    final firstNotifier = container.read(first.notifier);
    final secondNotifier = container.read(second.notifier);

    expect(identical(firstNotifier, secondNotifier), isFalse);
    expect(firstSubscription.read(), const PostAudioState.idle());

    firstSubscription.close();
    await container.pump();

    expect(firstNotifier.mounted, isFalse);
    expect(secondNotifier.mounted, isTrue);
    secondSubscription.close();
    await container.pump();
    expect(secondNotifier.mounted, isFalse);
  });

  test('마이크 권한을 거부하면 임시 파일을 만들지 않는다', () async {
    recorder.permissionGranted = false;

    await notifier.startRecording();

    expect(recorder.calls, ['permission']);
    expect(
      notifier.state,
      const PostAudioState.failure(PostAudioFailure.permissionDenied),
    );
  });

  test('권한 확인 중 숨겨지면 늦게 권한을 받아도 녹음을 시작하지 않는다', () async {
    recorder.pendingPermission = Completer<bool>();
    final starting = notifier.startRecording();
    expect(notifier.state, const PostAudioState.preparing());

    final hiding = notifier.stopForBackground();
    recorder.pendingPermission!.complete(true);
    await starting;
    await hiding;

    expect(recorder.calls, ['permission']);
    expect(notifier.state, const PostAudioState.idle());

    // 다음 녹음 버튼까지 막지는 않는다.
    await notifier.startRecording();
    expect(notifier.state, isA<PostAudioRecording>());
    await notifier.discardRecording();
  });

  test('임시 경로 생성 중 숨겨지면 만들어진 경로를 정리하고 시작하지 않는다', () async {
    recorder.pathEntered = Completer<void>();
    recorder.pendingPath = Completer<String>();
    final starting = notifier.startRecording();
    await recorder.pathEntered!.future;

    final hiding = notifier.stopForBackground();
    recorder.pendingPath!.complete(_clipPath);
    await starting;
    await hiding;

    expect(recorder.calls, ['permission', 'discard', 'createPath', 'discard']);
    expect(notifier.state, const PostAudioState.idle());
  });

  test('녹음기 시작 호출 중 숨겨지면 타이머 없이 한 번만 종료한다', () async {
    recorder.startEntered = Completer<void>();
    recorder.pendingStart = Completer<void>();
    final starting = notifier.startRecording();
    await recorder.startEntered!.future;

    final hiding = notifier.stopForBackground();
    final hidingAgain = notifier.stopForBackground();
    recorder.pendingStart!.complete();
    await starting;
    await hiding;
    await hidingAgain;

    expect(recorder.calls, [
      'permission',
      'discard',
      'createPath',
      'start',
      'stop',
    ]);
    expect(notifier.state, const PostAudioState.ready(filePath: _clipPath));
    expect(stopwatch.isRunning, isFalse);
  });

  test('녹음 종료는 파일을 남기고 중복 종료·취소를 막는다', () async {
    await notifier.startRecording();
    expect(recorder.calls, ['permission', 'discard', 'createPath', 'start']);
    recorder.calls.clear();
    recorder.pendingStop = Completer<String?>();

    final stopping = notifier.stopRecording();
    expect(notifier.state, const PostAudioState.stopping());
    await notifier.stopRecording();
    await notifier.discardRecording();
    recorder.pendingStop!.complete(_clipPath);
    await stopping;

    expect(recorder.calls, ['stop']);
    expect(notifier.state, const PostAudioState.ready(filePath: _clipPath));
  });

  test('녹음 취소는 파일을 버리고 대기 상태로 돌아간다', () async {
    await notifier.startRecording();
    recorder.calls.clear();

    await notifier.discardRecording();

    expect(recorder.calls, ['discard']);
    expect(notifier.state, const PostAudioState.idle());
  });

  test('이미 종료된 녹음도 삭제할 수 있다', () async {
    await notifier.startRecording();
    await notifier.stopRecording();
    recorder.calls.clear();

    await notifier.discardRecording();

    expect(recorder.calls, ['discard']);
    expect(notifier.state, const PostAudioState.idle());
  });

  test('빈 녹음은 폐기하고 미리 듣기 상태로 전환하지 않는다', () async {
    recorder.stoppedPath = null;
    await notifier.startRecording();
    recorder.calls.clear();

    await notifier.stopRecording();

    expect(recorder.calls, ['stop', 'discard']);
    expect(
      notifier.state,
      const PostAudioState.failure(PostAudioFailure.emptyRecording),
    );
  });

  test('시작과 종료가 실패하면 각각 정리를 시도한다', () async {
    recorder.failStart = true;
    await notifier.startRecording();
    expect(recorder.calls.last, 'discard');
    expect(
      notifier.state,
      const PostAudioState.failure(PostAudioFailure.startFailed),
    );

    recorder.failStart = false;
    await notifier.startRecording();
    recorder.calls.clear();
    recorder.failStop = true;
    await notifier.stopRecording();
    expect(recorder.calls, ['stop', 'discard']);
    expect(
      notifier.state,
      const PostAudioState.failure(PostAudioFailure.stopFailed),
    );
  });

  test('파일 정리 실패는 취소 성공으로 표시하지 않고 다시 시도할 수 있다', () async {
    await notifier.startRecording();
    recorder.failDiscard = true;
    await notifier.discardRecording();
    expect(
      notifier.state,
      const PostAudioState.failure(PostAudioFailure.discardFailed),
    );

    recorder.failDiscard = false;
    await notifier.discardRecording();
    expect(notifier.state, const PostAudioState.idle());
  });
}
