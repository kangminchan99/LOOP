import '../models/ble_device_model.dart';

abstract class AbstractBleRepository {
  Future<void> startScan();

  Future<void> stopScan();

  Stream<List<BleDeviceModel>> watchScanResults();

  Future<void> connect(String deviceId);

  Future<void> disconnect(String deviceId);
}
