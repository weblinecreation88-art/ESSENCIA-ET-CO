import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/proche_repository.dart";
import "../data/profile_photo_repository.dart";

final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>(
  (ref) => ProfilePhotoRepository(),
);

final procheRepositoryProvider = Provider<ProcheRepository>(
  (ref) => ProcheRepository(),
);
