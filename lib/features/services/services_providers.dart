import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/dio_client.dart';

import 'data/services_remote_datasource.dart';
import 'data/services_repository_impl.dart';
import 'domain/entities/service.dart';
import 'domain/repositories/services_repository.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ServicesRepositoryImpl(ServicesRemoteDataSource(dio));
});

/// Lista de servicios de la organización (reusable desde Crear cita u otras pantallas).
final servicesListProvider =
    FutureProvider.autoDispose<List<Service>>((ref) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.fetchServices();
});
