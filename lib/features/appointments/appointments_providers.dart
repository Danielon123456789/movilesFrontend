import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/dio_client.dart';

import '../agenda/presentation/controllers/agenda_controller.dart';
import '../auth/data/backend_session_providers.dart';
import 'data/appointments_remote_datasource.dart';
import 'data/appointments_repository_impl.dart';
import 'domain/appointment_query_scope.dart';
import 'domain/entities/appointment.dart';
import 'domain/repositories/appointments_repository.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentsRepositoryImpl(
    AppointmentsRemoteDataSource(dio),
  );
});

/// Citas del mes visible (clave: primer día del mes a las 00:00 local).
final monthAppointmentsProvider = FutureProvider.autoDispose
    .family<List<Appointment>, DateTime>((ref, monthAnchor) async {
  final normalized = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final rangeEnd = DateTime(normalized.year, normalized.month + 1, 1);

  final userAsync = ref.watch(currentBackendUserProvider);
  if (userAsync.isLoading) return [];
  if (userAsync.hasError) {
    debugPrint(
      'monthAppointmentsProvider: currentBackendUser error ${userAsync.error}',
    );
    return [];
  }

  final backendUser = userAsync.value;
  if (backendUser == null) return [];

  final role = backendUser.role.toLowerCase();
  final AppointmentQueryScope scope;
  if (role == 'therapist') {
    scope = AppointmentQueryScope.therapistMe;
  } else if (role == 'admin' || role == 'secretary') {
    scope = AppointmentQueryScope.organization;
  } else {
    debugPrint('monthAppointmentsProvider: unsupported role "$role"');
    return [];
  }

  final repo = ref.watch(appointmentsRepositoryProvider);
  try {
    return await repo.fetchAppointmentsForMonthRange(
      rangeStart: normalized,
      rangeEnd: rangeEnd,
      scope: scope,
    );
  } catch (e, st) {
    debugPrint('monthAppointmentsProvider: $e\n$st');
    return [];
  }
});

/// Todas las citas de un paciente (sin filtro de fecha). Solo ADMIN/SECRETARY.
final patientAppointmentsProvider = FutureProvider.autoDispose
    .family<List<Appointment>, String>((ref, patientId) async {
  final repo = ref.watch(appointmentsRepositoryProvider);
  try {
    return await repo.fetchAppointmentsForPatient(patientId);
  } catch (e, st) {
    debugPrint('patientAppointmentsProvider: $e\n$st');
    return [];
  }
});

/// Días del mes visible con al menos una cita (para puntitos). Ante carga o
/// error, conjunto vacío sin bloquear la UI.
final daysWithAppointmentsForCalendarProvider =
    Provider<AsyncValue<Set<int>>>((ref) {
  final agenda = ref.watch(agendaControllerProvider);
  final monthKey =
      DateTime(agenda.visibleMonth.year, agenda.visibleMonth.month, 1);
  final listAsync = ref.watch(monthAppointmentsProvider(monthKey));

  return listAsync.when(
    data: (list) {
      final set = <int>{};
      final y = agenda.visibleMonth.year;
      final m = agenda.visibleMonth.month;
      for (final a in list) {
        final d = a.startDate;
        if (d.year == y && d.month == m) {
          set.add(d.day);
        }
      }
      return AsyncData(set);
    },
    loading: () => const AsyncData(<int>{}),
    error: (e, st) {
      debugPrint('daysWithAppointmentsForCalendarProvider: $e');
      return const AsyncData(<int>{});
    },
  );
});
