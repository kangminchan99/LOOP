import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:loop/src/features/attendance/presentation/providers/attendance_state.dart';

class AttendanceDialog extends ConsumerWidget {
  const AttendanceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (state) {
          AttendanceLoading() => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),

          AttendanceCheckingIn(:final attendance) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '출석 처리 중...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (attendance != null) ...[
                _InfoRow(label: '연속 출석', value: '${attendance.streakCount}일'),
                const SizedBox(height: 8),
                _InfoRow(label: '보유 포인트', value: '${attendance.totalPoint}P'),
                const SizedBox(height: 20),
              ],
              const CircularProgressIndicator(),
            ],
          ),

          AttendanceSuccess(:final attendance) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                attendance.checkedToday
                    ? Icons.check_circle
                    : Icons.calendar_month,
                size: 56,
                color: attendance.checkedToday ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                '출석체크',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _InfoRow(label: '연속 출석', value: '${attendance.streakCount}일'),
              const SizedBox(height: 8),
              _InfoRow(label: '보유 포인트', value: '${attendance.totalPoint}P'),
              const SizedBox(height: 8),
              _InfoRow(label: '오늘 보상', value: '+${attendance.rewardPoint}P'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: attendance.checkedToday
                      ? null
                      : () {
                          ref.read(attendanceProvider.notifier).checkIn();
                        },
                  child: Text(attendance.checkedToday ? '오늘 출석 완료' : '출석 체크하기'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('닫기'),
              ),
            ],
          ),

          AttendanceError(:final message) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '출석체크 실패',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('닫기'),
              ),
            ],
          ),

          _ => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
