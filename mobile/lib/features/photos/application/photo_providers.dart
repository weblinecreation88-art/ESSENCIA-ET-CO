import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/photo_repository.dart";

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => PhotoRepository(),
);
