import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:loop/src/features/admin/domain/models/server_status_model.dart';

class AdminSseDataSource {
  AdminSseDataSource({
    required FlutterSecureStorage secureStorage,
    http.Client? client,
  }) : _secureStorage = secureStorage,
       _client = client ?? http.Client();

  final FlutterSecureStorage _secureStorage;
  final http.Client _client;

  bool _isClosed = false;

  Stream<ServerStatusModel> watchServerStatus() async* {
    final accessToken = await _secureStorage.read(key: kAccessTokenKey);

    if (accessToken == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final request = http.Request(
      'GET',
      Uri.parse('$apiUrl/admin/sse/server-status'),
    );

    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Authorization': 'Bearer $accessToken',
    });

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw StateError('SSE 연결 실패: ${response.statusCode}');
    }

    try {
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) {
          continue;
        }

        final jsonString = line.substring(5).trim();

        if (jsonString.isEmpty) {
          continue;
        }

        final json = jsonDecode(jsonString) as Map<String, dynamic>;

        yield ServerStatusModel.fromJson(json);
      }
    } on http.ClientException catch (error) {
      if (_isClosed) {
        return;
      }

      throw StateError('SSE 연결이 끊어졌습니다: $error');
    }
  }

  void close() {
    _isClosed = true;
    _client.close();
  }
}
