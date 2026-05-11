import '../appointment_query_scope.dart';
import '../entities/appointment.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> fetchAppointmentsForMonthRange({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required AppointmentQueryScope scope,
  });

  Future<Appointment> createAppointment({
    required String patientId,
    required String therapistId,
    required String serviceId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Appointment> updateAppointment(
    String id, {
    String? patientId,
    String? therapistId,
    String? serviceId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> deleteAppointment(String id);

  Future<Appointment> updateAppointmentNotes(String id, String notes);

  Future<List<Appointment>> fetchAppointmentsForPatient(String patientId);
}
