import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/bluetooth/domain/models/ble_device_model.dart';

part 'ble_state.freezed.dart';

@freezed
abstract class BleState with _$BleState {
  const factory BleState({
    @Default(false) bool isScanning,
    @Default([]) List<BleDeviceModel> devices,
    String? errorMessage,
  }) = _BleState;
}
