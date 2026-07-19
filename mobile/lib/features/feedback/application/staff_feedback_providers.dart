import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/staff_feedback_repository.dart";

final staffFeedbackRepositoryProvider = Provider<StaffFeedbackRepository>(
  (ref) => StaffFeedbackRepository(),
);
