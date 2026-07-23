import "package:essencia_co/features/services/domain/booking.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("AppointmentMode", () {
    test("chaque modalité fait un aller-retour de stockage", () {
      for (final mode in AppointmentMode.values) {
        expect(AppointmentMode.fromStorage(mode.storageValue), mode);
      }
    });

    test("une ancienne réservation reste un rendez-vous en présentiel", () {
      expect(AppointmentMode.fromStorage(null), AppointmentMode.inPerson);
      expect(AppointmentMode.fromStorage("inconnue"), AppointmentMode.inPerson);
    });
  });
}
