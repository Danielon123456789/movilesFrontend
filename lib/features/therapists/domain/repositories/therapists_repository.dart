import '../entities/therapist.dart';

abstract class TherapistsRepository {
  Future<List<Therapist>> fetchTherapists({String? query});

  Future<Therapist> createTherapist({
    required String name,
    String? email,
    String? phoneNumber,
  });

  Future<Therapist> updateTherapist(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
  });

  Future<void> deleteTherapist(String id);
}
