/// Cita tal como la consume la capa de agenda/calendario (API).
///
/// Para evitar conflicto con la entidad UI legacy en agenda, usar imports con
/// prefijo donde haga falta (p. ej. `as ui`).
class Appointment {
  const Appointment({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.patientId,
    required this.patientName,
    required this.therapistId,
    required this.therapistName,
    this.serviceId,
    this.serviceName,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final String patientId;
  final String patientName;
  final String therapistId;
  final String therapistName;
  final String? serviceId;
  final String? serviceName;
}
