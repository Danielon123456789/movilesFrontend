import 'package:dio/dio.dart';

import 'models/service_model.dart';

/// [AppConfig.baseUrl] no incluye `/api/v1`; las rutas deben llevar el prefijo completo.
class ServicesRemoteDataSource {
  ServicesRemoteDataSource(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/services';

  Future<List<ServiceModel>> fetchServices() async {
    final response = await _dio.get(_base);
    return (response.data as List)
        .map(
          (e) => ServiceModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }

  Future<ServiceModel> createService({
    required String name,
    required int duration,
  }) async {
    final response = await _dio.post(
      _base,
      data: <String, dynamic>{
        'name': name,
        'duration': duration,
      },
    );
    return ServiceModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<ServiceModel> updateService(
    int id, {
    String? name,
    int? duration,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'duration': duration,
    }..removeWhere((_, v) => v == null);
    final response = await _dio.patch('$_base/$id', data: data);
    return ServiceModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteService(int id) async {
    await _dio.delete('$_base/$id');
  }
}
