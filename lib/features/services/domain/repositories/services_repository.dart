import '../entities/service.dart';

abstract class ServicesRepository {
  Future<List<Service>> fetchServices();

  Future<Service> createService({
    required String name,
    required int duration,
  });

  Future<Service> updateService(String id, {String? name, int? duration});

  Future<void> deleteService(String id);
}
