import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/dialogs/confirm_delete_dialog.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/swipe_actions_row.dart';
import '../controllers/agenda_controller.dart';
import '../models/appointment_view_model.dart';
import '../providers/selected_day_appointments_providers.dart';
import '../widgets/agenda_calendar_section.dart';
import '../../../appointments/appointments_providers.dart';
import '../widgets/create_appointment_modal.dart';
import '../widgets/edit_appointment_modal.dart';
import '../widgets/agenda_empty_state.dart';
import '../widgets/appointment_card.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  bool _isExpanded = true;
  String? _selectedTherapist;

  List<String> _therapists = ['Todos'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaControllerProvider);
    final appointmentsAsync = ref.watch(
      selectedDayAppointmentViewModelsProvider,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(title: 'Agenda'),
            Expanded(
              child: SlidableAutoCloseBehavior(
                child: ListView(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    AgendaCalendarSection(
                      onDayTap: (date) =>
                          context.push(Routes.agendaDayPath(date)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _isExpanded = !_isExpanded),
                              child: Row(
                                children: [
                                  Text(
                                    'Citas',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_right,
                                    size: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) => setState(() {
                              _selectedTherapist = value == 'Todos'
                                  ? null
                                  : value;
                            }),
                            offset: const Offset(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (_) => _therapists
                                .map(
                                  (t) => PopupMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            (t == 'Todos' &&
                                                    _selectedTherapist ==
                                                        null) ||
                                                t == _selectedTherapist
                                            ? AppColors.appointmentAccent
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedTherapist ?? 'Terapeutas',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.appointmentAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                    color: AppColors.appointmentAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    if (_isExpanded) ...[
                      ...appointmentsAsync.when(
                        loading: () => [
                          const SizedBox(height: AppSpacing.sm),
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                        error: (e, _) => [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Text(
                              'No se pudieron cargar las citas.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        data: (allVms) {
                          _therapists = ['Todos'];
                          _therapists.addAll(
                            allVms.map((appointment) => appointment.therapist),
                          );
                          final appointments = _selectedTherapist == null
                              ? allVms
                              : allVms
                                    .where(
                                      (vm) =>
                                          vm.therapist == _selectedTherapist,
                                    )
                                    .toList();

                          if (appointments.isEmpty) {
                            return [const AgendaEmptyState()];
                          }

                          final widgets = <Widget>[
                            for (var i = 0; i < appointments.length; i++) ...[
                              SwipeActionsRow(
                                key: ValueKey(
                                  'agenda_home_${appointments[i].id}',
                                ),
                                groupTag: 'agenda_home',
                                onEdit: () => _showEditAppointmentModal(
                                  context,
                                  appointments[i],
                                ),
                                onDelete: () => _confirmDeleteAppointment(
                                  context,
                                  appointments[i],
                                ),
                                child: AppointmentCard(
                                  appointment: appointments[i],
                                  onTap: () => context.push(
                                    '/agenda/detail',
                                    extra: appointments[i]
                                        .toLegacyAgendaAppointment(),
                                  ),
                                ),
                              ),
                              if (i < appointments.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.divider,
                                  indent: AppSpacing.md,
                                  endIndent: AppSpacing.md,
                                ),
                            ],
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.divider,
                              indent: AppSpacing.md,
                              endIndent: AppSpacing.md,
                            ),
                          ];
                          return widgets;
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    AppointmentViewModel appointment,
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

      final start = appointment.startDate.toLocal();
      final agenda = ref.read(agendaControllerProvider);
      final anchors = <DateTime>{
        DateTime(start.year, start.month, 1),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar la cita: $e')));
    }
  }

  static Future<void> _showEditAppointmentModal(
    BuildContext context,
    AppointmentViewModel appointment,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        return;
      case 1:
        context.go(Routes.patients);
        return;
      case 2:
        context.go(Routes.therapists);
        return;
      case 3:
        context.go(Routes.dashboard);
        return;
    }
  }

  static Future<void> _showCreateAppointmentModal(
    BuildContext context,
    DateTime selectedDate,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateAppointmentModal(initialDate: selectedDate),
    );
  }
}
