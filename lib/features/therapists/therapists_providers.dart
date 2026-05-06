import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import 'data/therapists_remote_datasource.dart';
import 'data/therapists_repository_impl.dart';
import 'domain/repositories/therapists_repository.dart';

final therapistsRemoteDataSourceProvider = Provider<TherapistsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TherapistsRemoteDataSource(dio);
});

final therapistsRepositoryProvider = Provider<TherapistsRepository>((ref) {
  final remote = ref.watch(therapistsRemoteDataSourceProvider);
  return TherapistsRepositoryImpl(remote);
});
