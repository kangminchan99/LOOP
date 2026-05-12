import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';

class Helpers {
  Future<void> initializeApp() async {
    // ProviderContainer를 사용하여 initializationProvider 실행
    final container = ProviderContainer();
    await container.read(initializationProvider.future);
  }
}
