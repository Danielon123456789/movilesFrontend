import 'package:dio/dio.dart';

import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/core/network/dio_error_mapper.dart';

import '../domain/entities/service.dart';
import '../domain/repositories/services_repository.dart';
import 'models/service_model.dart';
import 'services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl(this._remote);

  final ServicesRemoteDataSource _remote;

  /// Único lugar donde el `id` numérico del API se convierte a `String` de dominio.
  Service _toEntity(ServiceModel model) {
    return Service(
      id: model.id.toString(),
      name: model.name,
      duration: model.duration,
    );
  }

  @override
  Future<List<Service>> fetchServices() async {
    try {
      final models = await _remote.fetchServices();
      return models.map(_toEntity).toList(growable: false);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Service> createService({
    required String name,
    required int duration,
  }) async {
    try {
      final model = await _remote.createService(name: name, duration: duration);
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<Service> updateService(String id, {String? name, int? duration}) async {
    try {
      final model = await _remote.updateService(
        int.parse(id),
        name: name,
        duration: duration,
      );
      return _toEntity(model);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await _remote.deleteService(int.parse(id));
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    }
  }
}
