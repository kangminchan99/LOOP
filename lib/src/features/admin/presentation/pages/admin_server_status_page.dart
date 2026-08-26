import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/features/admin/domain/models/server_status_model.dart';
import 'package:loop/src/features/admin/presentation/providers/admin_sse_providers.dart';

class AdminServerStatusPage extends ConsumerWidget {
  const AdminServerStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverStatusAsync = ref.watch(serverStatusStreamProvider);

    return DefaultLayout(
      appBarTitle: '서버 상태',
      child: serverStatusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('서버 상태 연결 실패: $error')),
        data: (status) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusCard(
                title: '서버 시간',
                value: status.serverTime,
                icon: Icons.schedule,
              ),
              const SizedBox(height: 12),
              _StatusCard(
                title: '실행 시간',
                value: _formatUptime(status.uptimeSeconds),
                icon: Icons.timer,
              ),
              const SizedBox(height: 12),
              _MemoryStatusCard(memory: status.memory),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUptime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $remainingSeconds초';
    }

    if (minutes > 0) {
      return '$minutes분 $remainingSeconds초';
    }

    return '$remainingSeconds초';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryStatusCard extends StatelessWidget {
  const _MemoryStatusCard({required this.memory});

  final ServerMemoryStatusModel memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                '메모리',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MemoryRow(label: 'RSS', value: '${memory.rssMb} MB'),
          const SizedBox(height: 8),
          _MemoryRow(label: 'Heap Used', value: '${memory.heapUsedMb} MB'),
          const SizedBox(height: 8),
          _MemoryRow(label: 'Heap Total', value: '${memory.heapTotalMb} MB'),
        ],
      ),
    );
  }
}

class _MemoryRow extends StatelessWidget {
  const _MemoryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
