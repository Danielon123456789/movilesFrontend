import 'package:dio/dio.dart';

import 'models/therapist_model.dart';

class TherapistsRemoteDataSource {
  TherapistsRemoteDataSource(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/users';

  Future<List<TherapistModel>> fetchTherapists({String? query}) async {
    final response = await _dio.get(
      _base,
      queryParameters: {
        'role': 'therapist',
        if (query != null && query.isNotEmpty) 'query': query,
      },
    );
    return (response.data as List)
        .map((e) => TherapistModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<TherapistModel> createTherapist({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': 'therapist',
    }..removeWhere((_, v) => v == null);

    final response = await _dio.post(_base, data: data);
    return TherapistModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<TherapistModel> updateTherapist(
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
    return TherapistModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteTherapist(int id) async {
    await _dio.delete('$_base/$id');
  }
}
