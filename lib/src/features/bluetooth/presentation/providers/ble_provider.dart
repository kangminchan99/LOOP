import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/bluetooth/data/data_sources/local/mock_ble_data_source.dart';
import 'package:loop/src/features/bluetooth/data/repositories/ble_repository_impl.dart';
import 'package:loop/src/features/bluetooth/domain/repositories/abstract_ble_repository.dart';
import 'package:loop/src/features/bluetooth/domain/usecases/ble_usecase.dart';
import 'package:loop/src/features/bluetooth/presentation/providers/ble_notifier.dart';
import 'package:loop/src/features/bluetooth/presentation/providers/ble_state.dart';

// 목 BLE 데이터 소스 Provider
//
// 지금은 실제 BLE 기기가 없어도 테스트할 수 있도록 MockBleDataSource를 사용한다.
// 나중에 실제 BLE 연동 시 이 부분을 실제 DataSource로 교체하면 된다.
final mockBleDataSourceProvider = Provider<MockBleDataSource>((ref) {
  final dataSource = MockBleDataSource();

  ref.onDispose(() {
    dataSource.dispose();
  });

  return dataSource;
});

// BLE Repository Provider
//
// 화면이나 UseCase는 구현체가 아니라 AbstractBleRepository를 바라보게 한다.
// 덕분에 Mock 구현에서 실제 BLE 구현으로 바꿔도 상위 계층 코드를 덜 수정한다.
final bleRepositoryProvider = Provider<AbstractBleRepository>((ref) {
  final dataSource = ref.watch(mockBleDataSourceProvider);

  return BleRepositoryImpl(dataSource);
});

// BLE UseCase Provider
//
// Notifier 또는 화면에서 BLE 기능을 사용할 때 이 Provider를 주입받는다.
final bleUseCaseProvider = Provider<BleUseCase>((ref) {
  final repository = ref.watch(bleRepositoryProvider);

  return BleUseCase(repository);
});

final bleNotifierProvider = StateNotifierProvider<BleNotifier, BleState>((ref) {
  final bleUseCase = ref.watch(bleUseCaseProvider);

  return BleNotifier(bleUseCase);
});
