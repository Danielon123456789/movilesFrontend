import 'package:agenda/controllers/patient.controller.dart';
import 'package:dio/dio.dart';

import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/core/network/dio_error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/patients_repository.dart';
import '../../../models/patient.model.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final PatientController _patientController;

  PatientsRepositoryImpl(Ref ref)
    : _patientController = ref.read(patientControllerProvider);

  @override
  Future<List<Patient>> fetchPatients({String? query}) async {
    try {
      return await _patientController.getByQuery(query ?? '');
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Patient> createPatient({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      return await _patientController.create(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Patient> updatePatient(
    int id, {
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      return await _patientController.update(
        id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<void> deletePatient(int id) async {
    try {
      await _patientController.delete(id);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }
}
