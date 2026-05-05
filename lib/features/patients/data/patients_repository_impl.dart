import 'package:dio/dio.dart';

import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/core/network/dio_error_mapper.dart';

import '../domain/entities/patient.dart';
import '../domain/repositories/patients_repository.dart';
import 'models/patient_model.dart';
import 'patients_remote_datasource.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  PatientsRepositoryImpl(this._remote);

  final PatientsRemoteDataSource _remote;

  /// Único lugar donde el `id` numérico del API se convierte a `String` de dominio.
  Patient _toEntity(
    PatientModel model, {
    String? serviceLabelOverride,
  }) {
    return Patient(
      id: model.id.toString(),
      name: model.name,
      daysLabel: PatientModel.uiPlaceholderDaysLabel,
      serviceLabel:
          serviceLabelOverride ?? PatientModel.uiPlaceholderServiceLabel,
      isActive: model.active,
      email: model.email,
      phoneNumber: model.phoneNumber,
    );
  }

  @override
  Future<List<Patient>> fetchPatients({String? query}) async {
    try {
      final models = await _remote.fetchPatients(query: query);
      return models.map((m) => _toEntity(m)).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Patient> createPatient({
    required String name,
    required String serviceLabel,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final model = await _remote.createPatient(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      return _toEntity(model, serviceLabelOverride: serviceLabel);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Patient> updatePatient(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
    bool? active,
  }) async {
    try {
      final model = await _remote.updatePatient(
        int.parse(id),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        active: active,
      );
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await _remote.deletePatient(int.parse(id));
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }
}
