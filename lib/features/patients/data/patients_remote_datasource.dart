import 'package:dio/dio.dart';

import 'models/patient_model.dart';

/// [AppConfig.baseUrl] no incluye `/api/v1`; las rutas deben llevar el prefijo completo.
class PatientsRemoteDataSource {
  PatientsRemoteDataSource(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/patients';

  Future<List<PatientModel>> fetchPatients({String? query}) async {
    final response = await _dio.get(
      _base,
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
      },
    );
    return (response.data as List)
        .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<PatientModel> createPatient({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    }..removeWhere((_, v) => v == null);

    final response = await _dio.post(_base, data: data);
    return PatientModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<PatientModel> updatePatient(
    int id, {
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    }..removeWhere((_, v) => v == null);

    final response = await _dio.patch('$_base/$id', data: data);
    return PatientModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deletePatient(int id) async {
    await _dio.delete('$_base/$id');
  }
}
