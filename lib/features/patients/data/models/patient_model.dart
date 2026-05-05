/// Respuesta JSON del backend (`PatientDto`).
///
/// `email` y `phoneNumber` se replican en la entidad [Patient]. Los campos solo de
/// interfaz (`daysLabel`, `serviceLabel`, `isActive`) no vienen del API; el
/// repositorio aplica placeholders o overrides al mapear.
class PatientModel {
  PatientModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
  });

  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;

  // TODO(ui-only): sin equivalente en `PatientDto`; valores solo para mostrar en UI.
  static const String uiPlaceholderDaysLabel = '—';
  // TODO(ui-only): sin equivalente en `PatientDto`; al crear se puede sobreescribir desde el modal.
  static const String uiPlaceholderServiceLabel = '—';
  // TODO(ui-only): el backend no envía estado activo/inactivo del paciente.
  static const bool uiPlaceholderIsActive = true;

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
