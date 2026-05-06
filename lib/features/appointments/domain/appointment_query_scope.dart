/// Define qué endpoint usar para listar citas por rango.
enum AppointmentQueryScope {
  /// `GET /api/v1/appointments` (admin / secretary).
  organization,

  /// `GET /api/v1/appointments/therapist/me` (therapist; filtro por JWT).
  therapistMe,
}
