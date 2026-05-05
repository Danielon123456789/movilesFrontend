import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/service.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceController {
  final Dio _dio;
  final _prefix = '/api/v1/services';

  ServiceController(Ref ref) : _dio = ref.read(dioProvider);

  Future<Service> create({required String name, required int duration}) async {
    final response = await _dio.post(
      _prefix,
      data: {'name': name, 'duration': duration},
    );
    return Service.fromJson(response.data);
  }

  Future<List<Service>> getAll() async {
    final response = await _dio.get(_prefix);
    return (response.data as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }
}

final serviceControllerProvider = Provider((ref) => ServiceController(ref));
