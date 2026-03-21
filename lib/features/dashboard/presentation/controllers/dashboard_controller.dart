import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.monthlyAppointments,
    required this.monthlyCompleted,
    required this.inactivePatients,
    required this.activePatients,
  });

  final int monthlyAppointments;
  final int monthlyCompleted;
  final int inactivePatients;
  final int activePatients;
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  return const DashboardMetrics(
    monthlyAppointments: 0,
    monthlyCompleted: 0,
    inactivePatients: 1,
    activePatients: 3,
  );
});
