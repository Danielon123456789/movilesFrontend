import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/dialogs/confirm_delete_dialog.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/appointment.dart';
import '../../../appointments/appointments_providers.dart';
import '../controllers/agenda_controller.dart';
import '../models/appointment_view_model.dart';
import '../providers/selected_day_appointments_providers.dart';
import '../widgets/agenda_day_detail_header.dart';
import '../widgets/agenda_timeline.dart';
import '../widgets/agenda_week_strip.dart';
import '../widgets/create_appointment_modal.dart';
import '../widgets/edit_appointment_modal.dart';

class DailyAgendaScreen extends ConsumerStatefulWidget {
  const DailyAgendaScreen({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  ConsumerState<DailyAgendaScreen> createState() => _DailyAgendaScreenState();
}

class _DailyAgendaScreenState extends ConsumerState<DailyAgendaScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(agendaControllerProvider.notifier)
          .selectDate(widget.selectedDate);
    });
  }

  @override
  void didUpdateWidget(covariant DailyAgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      ref
          .read(agendaControllerProvider.notifier)
          .selectDate(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaControllerProvider);
    final selectedDate = state.selectedDate;
    final notifier = ref.read(agendaControllerProvider.notifier);

    final weekDays = weekContaining(selectedDate);
    final monthLabel = DateFormat('MMMM', 'es')
        .format(selectedDate)
        .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final dayTitle = isToday
        ? 'Hoy'
        : DateFormat('EEEE d', 'es')
              .format(selectedDate)
              .split(' ')
              .map((s) {
                return s[0].toUpperCase() + s.substring(1).toLowerCase();
              })
              .join(' ');

    final textTheme = Theme.of(context).textTheme;
    final appointmentsAsync =
        ref.watch(selectedDayAppointmentViewModelsProvider);

    final viewModels = appointmentsAsync.when(
      data: (vms) => vms,
      loading: () => <AppointmentViewModel>[],
      error: (e, _) => <AppointmentViewModel>[],
    );
    final legacyAppointments =
        viewModels.map((vm) => vm.toLegacyAgendaAppointment()).toList();

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Column(
        children: [
          AgendaDayDetailHeader(monthLabel: monthLabel),
          const SizedBox(height: AppSpacing.sm),
          AgendaWeekStrip(
            weekDays: weekDays,
            selectedDate: selectedDate,
            onDayTap: (d) => notifier.selectDate(d),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.subtleBorder.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SlidableAutoCloseBehavior(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  Text(
                    dayTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AgendaTimeline(
                    showCurrentTimeIndicator: isToday,
                    appointments: legacyAppointments,
                    agendaSwipeGroupTag: 'agenda_day_timeline',
                    onAppointmentTap: (appt) =>
                        context.push('/agenda/detail', extra: appt),
                    onAppointmentEdit: (appt) {
                      final vm = viewModels.firstWhere(
                        (v) => v.id == appt.id,
                        orElse: () => viewModels.first,
                      );
                      _showEditAppointmentModal(context, vm);
                    },
                    onAppointmentDelete: (appt) =>
                        _confirmDeleteAppointment(context, appt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () =>
              _showCreateAppointmentModal(context, state.selectedDate),
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Future<void> _confirmDeleteAppointment(
    BuildContext context,
    Appointment appointment,
  ) async {
    final ok = await showConfirmDeleteDialog(
      context,
      title: 'Eliminar cita',
      body: '¿Seguro que deseas eliminar la cita de "${appointment.title}"?',
    );
    if (!ok || !context.mounted) return;

    try {
      await ref
          .read(appointmentsRepositoryProvider)
          .deleteAppointment(appointment.id);

      final agenda = ref.read(agendaControllerProvider);
      final now = DateTime.now();
      final anchors = <DateTime>{
        DateTime(now.year, now.month, 1),
        DateTime(agenda.visibleMonth.year, agenda.visibleMonth.month, 1),
        DateTime(agenda.selectedDate.year, agenda.selectedDate.month, 1),
      };
      for (final a in anchors) {
        ref.invalidate(monthAppointmentsProvider(a));
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita eliminada correctamente.')),
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la cita: $e')),
      );
    }
  }

  static Future<void> _showEditAppointmentModal(
    BuildContext context,
    AppointmentViewModel appointment,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditAppointmentModal(appointment: appointment),
    );
  }

  static void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.agenda);
      case 1:
        context.go(Routes.patients);
      case 2:
        context.go(Routes.therapists);
      case 3:
        context.go(Routes.dashboard);
    }
  }

  static Future<void> _showCreateAppointmentModal(
    BuildContext context,
    DateTime selectedDate,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateAppointmentModal(initialDate: selectedDate),
    );
  }
}
