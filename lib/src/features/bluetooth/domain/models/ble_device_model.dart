import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_device_model.freezed.dart';
part 'ble_device_model.g.dart';

@freezed
abstract class BleDeviceModel with _$BleDeviceModel {
  const factory BleDeviceModel({
    /// BLE 기기의 고유 ID
    ///
    /// 실제 BLE 연동 시에는 remoteId, deviceId 같은 값이 들어간다.
    required String id,

    /// 화면에 보여줄 기기 이름
    ///
    /// 이름이 없는 BLE 기기도 있어서 실제 연동 때는 "이름 없는 기기" 같은 기본값 처리가 필요하다.
    required String name,

    /// 신호 세기
    ///
    /// RSSI 값은 보통 음수다.
    /// 0에 가까울수록 가까운 기기라고 보면 된다.
    required int rssi,

    /// 현재 앱에서 연결된 상태인지 여부
    required bool isConnected,
  }) = _BleDeviceModel;

  factory BleDeviceModel.fromJson(Map<String, dynamic> json) =>
      _$BleDeviceModelFromJson(json);
}
