import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_recorder_data_source.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/presentation/pages/board_write_page.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/post/presentation/widgets/post_audio_recorder_section.dart';

import 'post_cache_session_test.dart' show AnalyticsFake;
import 'post_cache_test.dart' show FakeRepository;

class _Recorder extends PostAudioRecorderDataSource {
  bool permissionGranted = true;
  int permissionRequests = 0;
  int starts = 0;
  int stops = 0;
  int discards = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
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
  late _Posts posts;

  setUp(() {
    recorder = _Recorder();
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

  testWidgets(
    'only a tap requests permission; stop keeps audio locally and delete resets it',
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
      await tester.pumpAndSettle();
      expect(recorder.discards, 2); // 새 녹음 전 정리 + 삭제
      expect(record, findsOneWidget);
      expect(posts.submitted, isEmpty);
    },
  );

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
