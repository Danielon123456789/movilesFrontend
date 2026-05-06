import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../appointments/appointments_providers.dart';
import '../controllers/agenda_controller.dart';
import '../models/appointment_view_model.dart';

final selectedDayAppointmentViewModelsProvider =
    Provider<AsyncValue<List<AppointmentViewModel>>>((ref) {
      final sel = ref.watch(
        agendaControllerProvider.select((s) => s.selectedDate),
      );
      final monthAnchor = DateTime(sel.year, sel.month, 1);
      final monthAsync = ref.watch(monthAppointmentsProvider(monthAnchor));

      return monthAsync.when(
        data: (apiList) {
          final filtered =
              apiList.where((a) {
                final local = a.startDate.toLocal();
                return local.year == sel.year &&
                    local.month == sel.month &&
                    local.day == sel.day;
              }).toList()
                ..sort(
                  (a, b) => a.startDate.compareTo(b.startDate),
                );

          final vms = filtered
              .map(AppointmentViewModel.fromApiAppointment)
              .toList(growable: false);

          return AsyncValue<List<AppointmentViewModel>>.data(vms);
        },
        loading: () => const AsyncValue<List<AppointmentViewModel>>.loading(),
        error: (Object e, StackTrace st) =>
            AsyncValue<List<AppointmentViewModel>>.error(e, st),
      );
    });
