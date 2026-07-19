import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/agenda_repository.dart";

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => AgendaRepository(),
);
