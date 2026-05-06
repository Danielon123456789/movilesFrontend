import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/features/patients/domain/entities/patient.dart';
import 'package:agenda/features/patients/patients_providers.dart';
import 'package:agenda/features/services/domain/entities/service.dart';
import 'package:agenda/features/services/services_providers.dart';
import 'package:agenda/features/therapists/domain/entities/therapist.dart';
import 'package:agenda/features/therapists/therapists_providers.dart';

/// Datos combinados para el formulario Crear cita (dropdowns).
class CreateAppointmentDraftData {
  CreateAppointmentDraftData({
    required this.patients,
    required this.therapists,
    required this.services,
  });

  final List<Patient> patients;
  final List<Therapist> therapists;
  final List<Service> services;
}

/// Carga en paralelo pacientes, terapeutas (`role=therapist`) y servicios de la org.
final createAppointmentDraftDataProvider =
    FutureProvider.autoDispose<CreateAppointmentDraftData>((ref) async {
      final patientsRepo = ref.watch(patientsRepositoryProvider);
      final therapistsRepo = ref.watch(therapistsRepositoryProvider);
      final servicesRepo = ref.watch(servicesRepositoryProvider);

      final patientsFuture = patientsRepo.fetchPatients();
      final therapistsFuture = therapistsRepo.fetchTherapists();
      final servicesFuture = servicesRepo.fetchServices();

      return CreateAppointmentDraftData(
        patients: await patientsFuture,
        therapists: await therapistsFuture,
        services: await servicesFuture,
      );
    });
