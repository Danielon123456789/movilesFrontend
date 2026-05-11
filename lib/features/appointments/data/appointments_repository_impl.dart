import 'package:dio/dio.dart';

import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/core/network/dio_error_mapper.dart';

import '../domain/appointment_query_scope.dart';
import '../domain/entities/appointment.dart';
import '../domain/repositories/appointments_repository.dart';
import 'appointments_remote_datasource.dart';
import 'models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._remote);

  final AppointmentsRemoteDataSource _remote;

  Appointment _toEntity(AppointmentModel m) {
    return Appointment(
      id: m.id.toString(),
      startDate: m.startDate,
      endDate: m.endDate,
      notes: m.notes,
      patientId: m.patient.id.toString(),
      patientName: m.patient.name ?? '—',
      therapistId: m.therapist.id.toString(),
      therapistName: m.therapist.name ?? '—',
      serviceId: m.service?.id.toString(),
      serviceName: m.service?.name,
    );
  }

  @override
  Future<List<Appointment>> fetchAppointmentsForMonthRange({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required AppointmentQueryScope scope,
  }) async {
    try {
      final models = await _remote.fetchAppointmentsForMonthRange(
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        scope: scope,
      );
      return models.map(_toEntity).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Appointment> createAppointment({
    required String patientId,
    required String therapistId,
    required String serviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final model = await _remote.createAppointment(
        patientId: int.parse(patientId),
        therapistId: int.parse(therapistId),
        serviceId: int.parse(serviceId),
        startDate: startDate,
        endDate: endDate,
      );
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Appointment> updateAppointment(
    String id, {
    String? patientId,
    String? therapistId,
    String? serviceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = await _remote.updateAppointment(
        int.parse(id),
        patientId: patientId != null ? int.parse(patientId) : null,
        therapistId: therapistId != null ? int.parse(therapistId) : null,
        serviceId: serviceId != null ? int.parse(serviceId) : null,
        startDate: startDate,
        endDate: endDate,
      );
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      await _remote.deleteAppointment(int.parse(id));
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Appointment> updateAppointmentNotes(String id, String notes) async {
    try {
      final model = await _remote.updateAppointmentNotes(int.parse(id), notes);
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<List<Appointment>> fetchAppointmentsForPatient(
    String patientId,
  ) async {
    try {
      final models = await _remote.fetchAppointmentsForPatient(
        int.parse(patientId),
      );
      return models.map(_toEntity).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }
}
