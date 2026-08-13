import 'package:loop/src/features/bluetooth/domain/models/ble_device_model.dart';
import 'package:loop/src/features/bluetooth/domain/repositories/abstract_ble_repository.dart';

class BleUseCase {
  const BleUseCase(this._repository);

  final AbstractBleRepository _repository;

  // BLE 스캔을 시작한다.
  Future<void> startScan() {
    return _repository.startScan();
  }

  // BLE 스캔을 중지한다.
  Future<void> stopScan() {
    return _repository.stopScan();
  }

  // BLE 스캔 결과를 실시간으로 구독한다.
  //
  // 기기가 발견되거나 연결 상태가 바뀌면
  // 새로운 List<BleDeviceModel>이 Stream으로 전달된다.
  Stream<List<BleDeviceModel>> watchScanResults() {
    return _repository.watchScanResults();
  }

  /// 특정 BLE 기기에 연결한다.
  Future<void> connect(String deviceId) {
    return _repository.connect(deviceId);
  }

  /// 특정 BLE 기기 연결을 해제한다.
  Future<void> disconnect(String deviceId) {
    return _repository.disconnect(deviceId);
  }
}
