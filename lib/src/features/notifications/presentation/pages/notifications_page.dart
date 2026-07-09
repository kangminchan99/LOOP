import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_providers.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_state.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return DefaultLayout(
      appBarTitle: '알림',
      actions: [
        TextButton(
          onPressed: () {
            ref.read(notificationProvider.notifier).markAllAsRead();
          },
          child: const Text('모두 읽음'),
        ),
      ],
      child: state.when(
        initial: () {
          return const SizedBox.shrink();
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        success: (notifications, unreadCount) {
          if (notifications.isEmpty) {
            return const Center(child: Text('아직 알림이 없어요.'));
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(notificationProvider.notifier)
                  .loadNotifications();
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return _NotificationTile(
                  notification: notification,
                  onTap: () async {
                    await ref
                        .read(notificationProvider.notifier)
                        .markAsRead(notification: notification);

                    final postId = notification.data?['postId'];

                    if (!context.mounted) {
                      return;
                    }

                    if (postId == null) {
                      return;
                    }

                    context.pushNamed(
                      AppRoute.postDetail.name,
                      pathParameters: {'postId': postId.toString()},
                    );
                  },
                );
              },
            ),
          );
        },
        failure: (message) {
          return Center(child: Text(message));
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.readAt == null;

    return ListTile(
      onTap: onTap,
      tileColor: isUnread ? Colors.blue.withValues(alpha: 0.06) : null,
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(notification.body),
      trailing: isUnread
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
