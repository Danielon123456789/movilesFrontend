/// Respuesta JSON del backend (`PatientDto`).
///
/// `email`, `phoneNumber` y `active` se replican en la entidad [Patient]. Los
/// campos solo de interfaz (`daysLabel`, `serviceLabel`) no vienen del API; el
/// repositorio aplica placeholders o overrides al mapear.
class PatientModel {
  PatientModel({
    required this.id,
    required this.name,
    required this.active,
    this.email,
    this.phoneNumber,
  });

  final int id;
  final String name;
  final bool active;
  final String? email;
  final String? phoneNumber;

  // TODO(ui-only): sin equivalente en `PatientDto`; valores solo para mostrar en UI.
  static const String uiPlaceholderDaysLabel = '—';
  // TODO(ui-only): sin equivalente en `PatientDto`; al crear se puede sobreescribir desde el modal.
  static const String uiPlaceholderServiceLabel = '—';

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final rawEmail = json['email'] ?? json['tutorEmail'];
    final rawPhone =
        json['phoneNumber'] ?? json['phone_number'] ?? json['tutorPhone'];
    final rawActive = json['active'];
    final active = rawActive is bool ? rawActive : true;

    return PatientModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      active: active,
      email: rawEmail is String ? rawEmail : null,
      phoneNumber: rawPhone is String ? rawPhone : null,
    );
  }
}
