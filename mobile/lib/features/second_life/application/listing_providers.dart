import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/listing_repository.dart";

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(),
);
