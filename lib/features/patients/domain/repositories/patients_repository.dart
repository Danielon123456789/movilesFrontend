import '../entities/patient.dart';

abstract class PatientsRepository {
  Future<List<Patient>> fetchPatients({String? query});

  /// El backend persiste `name` y opcionalmente `email`, `phoneNumber` y `active`.
  /// [serviceLabel] solo afecta la entidad en memoria (ver TODO en el controller).
  Future<Patient> createPatient({
    required String name,
    required String serviceLabel,
    String? email,
    String? phoneNumber,
  });

  Future<Patient> updatePatient(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
    bool? active,
  });

  Future<void> deletePatient(String id);
}
