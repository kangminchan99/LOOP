import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_status_model.freezed.dart';
part 'server_status_model.g.dart';

@freezed
abstract class ServerMemoryStatusModel with _$ServerMemoryStatusModel {
  const factory ServerMemoryStatusModel({
    required double rssMb,
    required double heapUsedMb,
    required double heapTotalMb,
  }) = _ServerMemoryStatusModel;

  factory ServerMemoryStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ServerMemoryStatusModelFromJson(json);
}

@freezed
abstract class ServerStatusModel with _$ServerStatusModel {
  const factory ServerStatusModel({
    required String type,
    required String serverTime,
    required int uptimeSeconds,
    required ServerMemoryStatusModel memory,
  }) = _ServerStatusModel;

  factory ServerStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusModelFromJson(json);
}
