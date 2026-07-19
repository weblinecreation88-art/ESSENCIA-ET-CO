import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/notification_repository.dart";

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);
