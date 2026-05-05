/// Errores de API HTTP para llamadas hechas con Dio.
///
/// **Decisión de proyecto:** `AuthController` sigue usando [FirebaseAuthException]
/// y mensajes en el estado; cualquier feature que llame al backend REST por Dio debe
/// capturar [DioException], mapear con [dioExceptionToMessage] y lanzar o exponer
/// [ApiException] para mantener un solo patrón de errores HTTP en `core/network/`.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
