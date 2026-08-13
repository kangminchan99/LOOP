import 'package:loop/src/features/bluetooth/data/data_sources/local/mock_ble_data_source.dart';
import 'package:loop/src/features/bluetooth/domain/models/ble_device_model.dart';
import 'package:loop/src/features/bluetooth/domain/repositories/abstract_ble_repository.dart';

class BleRepositoryImpl implements AbstractBleRepository {
  BleRepositoryImpl(this._mockBleDataSource);

  final MockBleDataSource _mockBleDataSource;

  @override
  Future<void> startScan() {
    return _mockBleDataSource.startScan();
  }

  @override
  Future<void> stopScan() {
    return _mockBleDataSource.stopScan();
  }

  @override
  Stream<List<BleDeviceModel>> watchScanResults() {
    return _mockBleDataSource.watchScanResults();
  }

  @override
  Future<void> connect(String deviceId) {
    return _mockBleDataSource.connect(deviceId);
  }

  @override
  Future<void> disconnect(String deviceId) {
    return _mockBleDataSource.disconnect(deviceId);
  }
}
