import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../appointments/appointments_providers.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';

final dashboardMonthAnchorProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final monthAppointmentsCountProvider = Provider<AsyncValue<int>>((ref) {
  final anchor = ref.watch(dashboardMonthAnchorProvider);
  return ref
      .watch(monthAppointmentsProvider(anchor))
      .whenData((list) => list.length);
});

final completedAppointmentsCountProvider = Provider<AsyncValue<int>>((ref) {
  final anchor = ref.watch(dashboardMonthAnchorProvider);
  final now = DateTime.now();
  return ref.watch(monthAppointmentsProvider(anchor)).whenData(
        (list) => list.where((a) => a.endDate.isBefore(now)).length,
      );
});

final activePatientsCountProvider = Provider<int>((ref) => ref
    .watch(patientsControllerProvider)
    .patients
    .where((p) => p.isActive)
    .length);

final inactivePatientsCountProvider = Provider<int>((ref) => ref
    .watch(patientsControllerProvider)
    .patients
    .where((p) => !p.isActive)
    .length);
