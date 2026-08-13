import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/bluetooth/domain/usecases/ble_usecase.dart';
import 'package:loop/src/features/bluetooth/presentation/providers/ble_state.dart';

class BleNotifier extends StateNotifier<BleState> {
  BleNotifier(this._bleUseCase) : super(const BleState()) {
    _scanSubscription = _bleUseCase.watchScanResults().listen((devices) {
      state = state.copyWith(devices: devices);
    });
  }

  final BleUseCase _bleUseCase;

  StreamSubscription? _scanSubscription;

  Future<void> startScan() async {
    try {
      state = state.copyWith(isScanning: true, errorMessage: null);

      await _bleUseCase.startScan();
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'BLE 스캔 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> stopScan() async {
    try {
      await _bleUseCase.stopScan();

      state = state.copyWith(isScanning: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'BLE 스캔 중지 중 오류가 발생했습니다.');
    }
  }

  Future<void> connect(String deviceId) async {
    try {
      state = state.copyWith(errorMessage: null);

      await _bleUseCase.connect(deviceId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'BLE 기기 연결 중 오류가 발생했습니다.');
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      state = state.copyWith(errorMessage: null);

      await _bleUseCase.disconnect(deviceId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'BLE 기기 연결 해제 중 오류가 발생했습니다.');
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}
