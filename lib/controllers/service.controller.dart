import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/service.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceController {
  final Ref _ref;

  ServiceController(this._ref);

  Future<Service> create({required String name, required int duration}) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post(
      '/services',
      data: {'name': name, 'duration': duration},
    );
    return Service.fromJson(response.data);
  }

  Future<List<Service>> getAll() async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/services');
    return (response.data as List)
        .map((json) => Service.fromJson(json))
        .toList();
  }
}

final serviceControllerProvider = Provider((ref) => ServiceController(ref));
