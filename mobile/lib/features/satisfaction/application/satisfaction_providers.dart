import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/satisfaction_repository.dart";

final satisfactionRepositoryProvider = Provider<SatisfactionRepository>(
  (ref) => SatisfactionRepository(),
);
