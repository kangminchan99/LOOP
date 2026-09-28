import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 초기 로드와 저장을 직렬화한다. 저장 성공 후에만 UI 상태를 확정한다.
abstract class PersistedPreferenceNotifier<T> extends StateNotifier<T> {
  PersistedPreferenceNotifier(
    super.initialState, {
    required this.storageKey,
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance {
    ready = _load();
    _tail = ready;
  }
  final String storageKey;
  final Future<SharedPreferences> Function() _loadPreferences;
  late final Future<void> ready;
  late Future<void> _tail;
  T decode(String? value);
  String encode(T value);

  Future<void> _load() async {
    try {
      final preferences = await _loadPreferences();
      if (mounted) state = decode(preferences.getString(storageKey));
    } catch (_) {
      // 초기 읽기 실패 시 기본값 유지. 다음 저장은 다시 시도할 수 있다.
    }
  }

  Future<void> save(T value) {
    final operation = _tail.then((_) async {
      if (!mounted) return;
      final preferences = await _loadPreferences();
      if (!mounted) return;
      if (!await preferences.setString(storageKey, encode(value))) {
        throw StateError('Preference persistence failed');
      }
      if (mounted) state = value;
    });
    // 실패를 호출자에게 전달하되 이후 변경의 큐를 막지 않는다.
    _tail = operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }
}
