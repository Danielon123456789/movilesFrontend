import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/dio_client.dart';

import 'data/patients_remote_datasource.dart';
import 'data/patients_repository_impl.dart';
import 'domain/repositories/patients_repository.dart';

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PatientsRepositoryImpl(PatientsRemoteDataSource(dio));
});
