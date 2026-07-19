import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/journal_repository.dart";

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(),
);
