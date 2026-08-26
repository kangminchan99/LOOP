import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/admin/data/data_sources/admin_sse_data_source.dart';
import 'package:loop/src/features/admin/domain/models/server_status_model.dart';

final adminSSeDataSourceProvider = Provider.autoDispose<AdminSseDataSource>((
  ref,
) {
  final dataSource = AdminSseDataSource(
    secureStorage: ref.watch(secureStorageProvider),
  );

  ref.onDispose(dataSource.close);

  return dataSource;
});

final serverStatusStreamProvider =
    StreamProvider.autoDispose<ServerStatusModel>((ref) {
      final dataSource = ref.watch(adminSSeDataSourceProvider);
      return dataSource.watchServerStatus();
    });
