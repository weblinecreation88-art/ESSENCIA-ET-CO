import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../application/notification_providers.dart";
import "../domain/app_notification.dart";

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String uid,
    AppNotification notification,
  ) async {
    if (!notification.read) {
      await ref
          .read(notificationRepositoryProvider)
          .markAsRead(uid, notification.id);
    }
    if (!context.mounted) return;
    switch (notification.type) {
      case NotificationType.message:
        context.push("/chat/${notification.relatedId}");
      case NotificationType.booking:
        context.push("/agenda");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<AppNotification>>(
              stream: ref
                  .read(notificationRepositoryProvider)
                  .watchNotifications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text("Aucune notification pour l'instant."),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                        ),
                        leading: Icon(
                          notification.type == NotificationType.message
                              ? Icons.chat_bubble_rounded
                              : Icons.event_available_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.read
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: notification.read
                            ? (notification.createdAt != null
                                  ? Text(
                                      DateFormat.Hm().format(notification.createdAt!),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    )
                                  : null)
                            : const CircleAvatar(
                                radius: 5,
                                backgroundColor: AppColors.secondary,
                              ),
                        onTap: () => _open(context, ref, user.uid, notification),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
