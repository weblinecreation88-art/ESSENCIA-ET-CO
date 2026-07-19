import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/booking_repository.dart";

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(),
);
