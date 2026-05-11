import '../../domain/entities/appointment.dart';
import '../../../appointments/domain/entities/appointment.dart' as api;

String _hourMinuteHm(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Fila de lista "Citas de hoy" / vista diaria derivada del API.
class AppointmentViewModel {
  const AppointmentViewModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.timeRange,
    required this.therapist,
    required this.patientId,
    required this.therapistId,
    this.serviceId,
    required this.startDate,
    required this.endDate,
    this.notes = '',
  });

  final String id;
  final String title;
  final String category;

  /// Fecha calendario local (solo día) de inicio de la cita.
  final DateTime date;

  /// `"HH:mm - HH:mm"` en hora local (requerido por `agenda_timeline` parser).
  final String timeRange;
  final String therapist;

  // Campos adicionales para pre-poblar el modal de edición.
  final String patientId;
  final String therapistId;
  final String? serviceId;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;

  factory AppointmentViewModel.fromApiAppointment(api.Appointment a) {
    final localStart = a.startDate.toLocal();
    final localEnd = a.endDate.toLocal();
    // TODO: si startDate y endDate locales caen en distintos días calendario,
    // hoy sólo clasificamos la cita por el día de inicio.

    final timeRange =
        '${_hourMinuteHm(localStart)} - ${_hourMinuteHm(localEnd)}';

    final dateCalendar = DateTime(
      localStart.year,
      localStart.month,
      localStart.day,
    );

    return AppointmentViewModel(
      id: a.id,
      title: a.patientName,
      category: a.serviceName ?? 'Sin servicio',
      date: dateCalendar,
      timeRange: timeRange,
      therapist: a.therapistName,
      patientId: a.patientId,
      therapistId: a.therapistId,
      serviceId: a.serviceId,
      startDate: a.startDate,
      endDate: a.endDate,
      notes: a.notes,
    );
  }

  /// Adapta el ViewModel al modelo UI legacy de `agenda/domain/entities/appointment.dart`.
  ///
  /// Existe únicamente para soportar pantallas que aún consumen la entidad legacy
  /// (detalle, daily agenda, timeline). Cuando esas pantallas migren a consumir
  /// directamente el ViewModel o la entidad de `appointments/domain/`, esta función
  /// y la entidad legacy podrán eliminarse.
  // TODO: eliminar tras migrar pantalla de detalle, daily agenda y timeline.
  Appointment toLegacyAgendaAppointment() {
    return Appointment(
      id: id,
      title: title,
      category: category,
      date: date,
      timeRange: timeRange,
      therapist: therapist,
      notes: notes,
    );
  }
}
