import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

Logger logger = Logger('AppLogger');

void initRootLogger() {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
  } else {
    // 프로덕션 환경에서는 로그 레벨을 OFF로 설정
    Logger.root.level = Level.OFF;
  }
  hierarchicalLoggingEnabled = true;

  Logger.root.onRecord.listen((record) {
    if (!kDebugMode) {
      return;
    }

    var start = '\x1b[90m';
    const end = '\x1b[0m';

    // 로그 레벨 별 색상 지정
    switch (record.level.name) {
      case 'INFO':
        start = '\x1b[92m';
        break;
      case 'WARNING':
        start = '\x1b[93m';
        break;
      case 'SEVERE':
        start = '\x1b[103m\x1b[31m';
        break;
      case 'SHOUT':
        start = '\x1b[41m\x1b[93m';
        break;
    }

    final message = '$end$start${record.message}$end';
    developer.log(
      message,
      name: record.loggerName.padRight(25),
      level: record.level.value,
    );
  });
}
