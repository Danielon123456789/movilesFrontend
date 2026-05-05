import 'package:agenda/models/patient.model.dart';

abstract class PatientsRepository {
  Future<List<Patient>> fetchPatients({String? query});

  Future<Patient> createPatient({
    required String name,
    String? email,
    String? phoneNumber,
  });

  Future<Patient> updatePatient(
    int id, {
    String? name,
    String? email,
    String? phoneNumber,
  });

  Future<void> deletePatient(int id);
}
