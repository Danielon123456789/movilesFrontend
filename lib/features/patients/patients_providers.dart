import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/patients_repository_impl.dart';
import 'domain/repositories/patients_repository.dart';

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  return PatientsRepositoryImpl(ref);
});
