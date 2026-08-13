import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/bluetooth/presentation/providers/ble_provider.dart';

class BlePage extends ConsumerWidget {
  const BlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bleNotifierProvider);
    final notifier = ref.read(bleNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('BLE 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: state.isScanning
                        ? null
                        : () {
                            notifier.startScan();
                          },
                    child: const Text('스캔 시작'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.isScanning
                        ? () {
                            notifier.stopScan();
                          }
                        : null,
                    child: const Text('스캔 중지'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: state.devices.isEmpty
                  ? const Center(child: Text('검색된 BLE 기기가 없습니다.'))
                  : ListView.separated(
                      itemCount: state.devices.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final device = state.devices[index];

                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text(
                            'id: ${device.id}\nrssi: ${device.rssi}',
                          ),
                          trailing: device.isConnected
                              ? OutlinedButton(
                                  onPressed: () {
                                    notifier.disconnect(device.id);
                                  },
                                  child: const Text('연결 해제'),
                                )
                              : FilledButton(
                                  onPressed: () {
                                    notifier.connect(device.id);
                                  },
                                  child: const Text('연결'),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
