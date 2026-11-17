import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_player_data_source.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_recorder_data_source.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/presentation/pages/board_write_page.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_preview_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_preview_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/post/presentation/widgets/post_audio_recorder_section.dart';

import 'post_cache_session_test.dart' show AnalyticsFake;
import 'post_cache_test.dart' show FakeRepository;

class _Recorder extends PostAudioRecorderDataSource {
  bool permissionGranted = true;
  Completer<bool>? pendingPermission;
  int permissionRequests = 0;
  int starts = 0;
  int stops = 0;
  int discards = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    final pending = pendingPermission;
    return pending == null ? permissionGranted : await pending.future;
  }

  @override
  Future<String> createRecordingPath() async => '/tmp/loop_test_clip.m4a';

  @override
  Future<void> start({required String path}) async => starts++;

  @override
  Future<String?> stop() async {
    stops++;
    return '/tmp/loop_test_clip.m4a';
  }

  @override
  Future<void> discardRecording() async => discards++;
}

class _FakePlayer implements PostAudioPlayerDataSource {
  // 위젯 테스트의 가상 시간 영역 안에서 Future를 생성한다.
  late final unloadDone = Completer<void>();
  late final _playbackChanges =
      StreamController<({bool playing, bool completed})>.broadcast();
  Completer<Duration?>? loadDone;
  int loadCalls = 0;
  int playCalls = 0;
  int unloadCalls = 0;

  @override
  Future<void> unloadFile() {
    unloadCalls++;
    return unloadDone.future;
  }

  @override
  Stream<({bool playing, bool completed})> get playbackChanges =>
      _playbackChanges.stream;

  @override
  Stream<void> get playbackErrors => const Stream.empty();

  @override
  Future<Duration?> loadFile(String filePath) async {
    loadCalls++;
    return await loadDone?.future ?? const Duration(seconds: 5);
  }

  @override
  Future<void> play() async {
    playCalls++;
    _playbackChanges.add((playing: true, completed: false));
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> seekToStart() async {}

  @override
  Future<void> dispose() => _playbackChanges.close();
}

class _Posts extends FakeRepository {
  final submitted = <PostRequestModel>[];

  @override
  Future<Either<Failure, PostDetailModel>> createPost(
    PostRequestModel request,
  ) async {
    submitted.add(request);
    return const Left(ServerFailure('test response', 400));
  }
}

class _RecordingClock extends Stopwatch {
  @override
  Duration get elapsed => const Duration(seconds: 5);
}

void main() {
  late _Recorder recorder;
  late _FakePlayer player;
  late _Posts posts;

  setUp(() {
    recorder = _Recorder();
    player = _FakePlayer();
    posts = _Posts();
  });

  Future<void> showWritePage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createPostRepositoryProvider.overrideWithValue(posts),
          analyticsServiceProvider.overrideWithValue(AnalyticsFake()),
          postAudioProvider.overrideWith(
            (_, _) => PostAudioNotifier(recorder, stopwatch: _RecordingClock()),
          ),
          postAudioPreviewProvider.overrideWith(
            (_, _) => PostAudioPreviewNotifier(player),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BoardWritePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> recordClip(WidgetTester tester) async {
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop recording'));
    await tester.pumpAndSettle();
  }

  void hideApp(WidgetTester tester) {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  }

  void resumeApp(WidgetTester tester) {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  testWidgets('hiding the app finishes recording and keeps the clip', (
    tester,
  ) async {
    await showWritePage(tester);
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();
    expect(find.text('Stop recording'), findsOneWidget);

    hideApp(tester);
    await tester.pump();
    expect(recorder.stops, 1);
    expect(recorder.discards, 1); // 녹음 시작 전 정리만 실행됨

    resumeApp(tester);
    await tester.pumpAndSettle();
    expect(find.text('Stop recording'), findsNothing);
    expect(find.text('Preview audio'), findsOneWidget);
    expect(recorder.starts, 1);
    expect(player.playCalls, 0);
  });

  testWidgets('inactive alone does not cancel the microphone permission flow', (
    tester,
  ) async {
    recorder.pendingPermission = Completer<bool>();
    await showWritePage(tester);
    await tester.tap(find.text('Record audio'));
    await tester.pump();
    expect(recorder.permissionRequests, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    recorder.pendingPermission!.complete(true);
    await tester.pumpAndSettle();

    expect(recorder.starts, 1);
    expect(recorder.stops, 0);
    expect(find.text('Stop recording'), findsOneWidget);
  });

  testWidgets(
    'hiding the app stops preview without discarding or autoplaying',
    (tester) async {
      await showWritePage(tester);
      await recordClip(tester);
      await tester.tap(find.text('Preview audio'));
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(player.playCalls, 1);
      expect(player.loadCalls, 1);

      hideApp(tester);
      await tester.pump();
      expect(player.unloadCalls, 1);
      player.unloadDone.complete();
      await tester.pumpAndSettle();

      resumeApp(tester);
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Preview audio'), findsOneWidget);
      expect(player.playCalls, 1);
      expect(recorder.discards, 1); // 녹음 시작 전 정리만 실행됨

      await tester.tap(find.text('Preview audio'));
      await tester.pumpAndSettle();
      expect(player.loadCalls, 2); // 다시 누르면 파일을 처음부터 준비한다.
      expect(player.playCalls, 2);
    },
  );

  testWidgets('hiding during file load prevents late playback', (tester) async {
    player.loadDone = Completer<Duration?>();
    await showWritePage(tester);
    await recordClip(tester);
    await tester.tap(find.text('Preview audio'));
    await tester.pumpAndSettle();
    expect(player.loadCalls, 1);
    expect(player.playCalls, 0);

    hideApp(tester);
    await tester.pump();
    expect(player.unloadCalls, 0); // 파일 로딩이 끝난 뒤 해제한다.
    player.loadDone!.complete(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(player.playCalls, 0);
    expect(player.unloadCalls, 1);

    player.unloadDone.complete();
    resumeApp(tester);
    await tester.pumpAndSettle();
    expect(player.playCalls, 0);
    expect(recorder.discards, 1);
    expect(find.text('Preview audio'), findsOneWidget);
  });

  testWidgets(
    'only a tap requests permission and deletion waits for the player to release the file',
    (tester) async {
      await showWritePage(tester);
      expect(recorder.permissionRequests, 0);
      final section = find.byType(PostAudioRecorderSection);
      final record = find.text('Record audio');
      await tester.tap(record);
      await tester.pumpAndSettle();
      expect(recorder.permissionRequests, 1);
      expect(recorder.starts, 1);
      expect(find.text('0:00 / 1:00'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0:05 / 1:00'), findsOneWidget);
      expect(section, findsOneWidget);

      await tester.tap(find.text('Stop recording'));
      await tester.pumpAndSettle();
      expect(recorder.stops, 1);
      expect(
        find.textContaining('Not attached to the post yet'),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete recording'));
      await tester.pump();
      expect(player.unloadCalls, 1);
      expect(recorder.discards, 1); // 아직 녹음 시작 전 정리만 실행됨

      player.unloadDone.complete();
      await tester.pumpAndSettle();
      expect(recorder.discards, 2); // 새 녹음 전 정리 + 삭제
      expect(record, findsOneWidget);
      expect(posts.submitted, isEmpty);
    },
  );

  testWidgets('a failed player release leaves the recording untouched', (
    tester,
  ) async {
    await showWritePage(tester);
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop recording'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete recording'));
    await tester.pump();
    expect(player.unloadCalls, 1);

    player.unloadDone.completeError(StateError('Could not release file'));
    await tester.pumpAndSettle();

    expect(recorder.discards, 1);
    expect(find.textContaining('Not attached to the post yet'), findsOneWidget);
    expect(find.text('Couldn’t play the recording.'), findsOneWidget);
    expect(find.text('Record audio'), findsNothing);
  });

  testWidgets('denying microphone access does not block a text post', (
    tester,
  ) async {
    recorder.permissionGranted = false;
    await showWritePage(tester);
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();
    expect(find.text('Microphone access is needed to record.'), findsOneWidget);
    expect(recorder.starts, 0);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Title');
    await tester.enterText(fields.at(1), 'Body');
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();
    expect(
      posts.submitted.single,
      const PostRequestModel(title: 'Title', content: 'Body'),
    );
  });

  testWidgets(
    'unsupported platforms keep the text form without audio controls',
    (tester) async {
      await showWritePage(tester);
      expect(find.byType(PostAudioRecorderSection), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(recorder.permissionRequests, 0);
    },
    variant: const TargetPlatformVariant({TargetPlatform.macOS}),
  );
}
