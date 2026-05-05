import 'package:dio/dio.dart';

/// Traduce [DioException] a mensaje legible (reutilizable por todas las features HTTP).
String dioExceptionToMessage(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  if (data is Map) {
    final msg = data['message'];
    if (msg is String) return msg;
    if (msg is List && msg.isNotEmpty && msg.first is String) {
      return msg.first as String;
    }
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Tiempo de espera agotado. Revisa tu conexión.';
    case DioExceptionType.badCertificate:
      return 'Error de certificado SSL.';
    case DioExceptionType.connectionError:
      return 'No se pudo conectar al servidor. ¿Está el backend en ejecución?';
    case DioExceptionType.cancel:
      return 'Solicitud cancelada.';
    case DioExceptionType.badResponse:
      return _messageForHttpStatus(status);
    case DioExceptionType.unknown:
      return e.message ?? 'Error de red desconocido.';
  }
}

String _messageForHttpStatus(int? status) {
  if (status == null) return 'Error HTTP desconocido.';
  if (status == 401) return 'No autorizado. Inicia sesión de nuevo.';
  if (status == 403) return 'No tienes permiso para esta acción.';
  if (status == 404) return 'Recurso no encontrado.';
  if (status == 422) return 'Datos inválidos.';
  if (status >= 500) return 'Error del servidor ($status).';
  return 'Error HTTP $status';
}
