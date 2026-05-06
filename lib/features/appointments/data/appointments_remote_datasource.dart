import 'package:dio/dio.dart';

import '../domain/appointment_query_scope.dart';
import 'models/appointment_model.dart';

/// Lista de citas por rango para el calendario mensual.
///
/// Fechas en **hora local** serializadas con [DateTime.toIso8601String]; el
/// backend valida con `@IsDateString()` y las parsea a `Date`.
class AppointmentsRemoteDataSource {
  AppointmentsRemoteDataSource(this._dio);

  final Dio _dio;

  static const _organizationPath = '/api/v1/appointments';
  static const _therapistMePath = '/api/v1/appointments/therapist/me';

  Future<List<AppointmentModel>> fetchAppointmentsForMonthRange({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required AppointmentQueryScope scope,
  }) async {
    final path = switch (scope) {
      AppointmentQueryScope.organization => _organizationPath,
      AppointmentQueryScope.therapistMe => _therapistMePath,
    };

    final response = await _dio.get(
      path,
      queryParameters: <String, dynamic>{
        'rangeStart': rangeStart.toIso8601String(),
        'rangeEnd': rangeEnd.toIso8601String(),
      },
    );

    return (response.data as List)
        .map(
          (e) => AppointmentModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<AppointmentModel> createAppointment({
    required int patientId,
    required int therapistId,
    required int serviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _organizationPath,
      data: <String, dynamic>{
        'patientId': patientId,
        'therapistId': therapistId,
        'serviceId': serviceId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AppointmentModel> updateAppointment(
    int id, {
    int? patientId,
    int? therapistId,
    int? serviceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = <String, dynamic>{
      'patientId': patientId,
      'therapistId': therapistId,
      'serviceId': serviceId,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    }..removeWhere((_, v) => v == null);
    final response = await _dio.patch<Map<String, dynamic>>(
      '$_organizationPath/$id',
      data: data,
    );
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteAppointment(int id) async {
    await _dio.delete('$_organizationPath/$id');
  }
}
