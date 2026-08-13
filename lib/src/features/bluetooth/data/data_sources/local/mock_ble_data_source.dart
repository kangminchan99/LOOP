import 'dart:async';

import 'package:loop/src/features/bluetooth/domain/models/ble_device_model.dart';

// Mock Data
class MockBleDataSource {
  final StreamController<List<BleDeviceModel>> _scanResultsController =
      StreamController<List<BleDeviceModel>>.broadcast();

  List<BleDeviceModel> _devices = const [];

  Stream<List<BleDeviceModel>> watchScanResults() {
    return _scanResultsController.stream;
  }

  Future<void> startScan() async {
    _devices = const [
      BleDeviceModel(
        id: 'mock-loop-beacon-1',
        name: 'Loop Beacon Mock',
        rssi: -55,
        isConnected: false,
      ),
      BleDeviceModel(
        id: 'mock-loop-sensor-1',
        name: 'Loop Sensor Mock',
        rssi: -72,
        isConnected: false,
      ),
      BleDeviceModel(
        id: 'mock-attendance-device-1',
        name: 'Loop Attendance Device',
        rssi: -63,
        isConnected: false,
      ),
    ];

    _scanResultsController.add(_devices);
  }

  Future<void> stopScan() async {
    _scanResultsController.add(_devices);
  }

  Future<void> connect(String deviceId) async {
    _devices = _devices.map((device) {
      if (device.id != deviceId) {
        return device;
      }

      return device.copyWith(isConnected: true);
    }).toList();

    _scanResultsController.add(_devices);
  }

  Future<void> disconnect(String deviceId) async {
    _devices = _devices.map((device) {
      if (device.id != deviceId) {
        return device;
      }

      return device.copyWith(isConnected: false);
    }).toList();

    _scanResultsController.add(_devices);
  }

  void dispose() {
    _scanResultsController.close();
  }
}
