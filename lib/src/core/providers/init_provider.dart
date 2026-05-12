import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:loop/src/core/network/dio_network.dart';
import 'package:loop/src/core/utils/log/app_logger.dart';

final loggerProvider = Provider<Logger>((ref) {
  initRootLogger();
  return logger;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  // 의존성 명시
  ref.watch(loggerProvider);
  final storage = ref.watch(secureStorageProvider); // ← 변수로 저장

  DioNetwork.initDio(storage); // ← 변수 사용
  return DioNetwork.appAPI;
});

final initializationProvider = FutureProvider<void>((ref) async {
  // 모든 provider 초기화
  ref.watch(loggerProvider);
  ref.watch(secureStorageProvider);
  ref.watch(dioProvider);
});
