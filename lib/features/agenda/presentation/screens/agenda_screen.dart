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
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/swipe_actions_row.dart';
import '../../domain/entities/appointment.dart';
import '../controllers/agenda_controller.dart';
import '../widgets/agenda_calendar_section.dart';
import '../widgets/create_appointment_modal.dart';
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

  static const _appointmentDeletePendingMessage =
      'La eliminación de citas desde la lista aún no está enlazada con el servidor.';

  static const _therapists = [
    'Todos',
    'Daniel Hernández',
    'Sergio Gómez',
    'Roberto Gómez',
    'Carlos Rodríguez',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaControllerProvider);
    final allAppointments = ref.watch(appointmentsForSelectedDateProvider);
    final appointments = _selectedTherapist == null
        ? allAppointments
        : allAppointments
              .where((a) => a.therapist == _selectedTherapist)
              .toList();

    final headerDate = DateFormat('EEEE, d \'de\' MMMM', 'es')
        .format(state.selectedDate)
        .split(' ')
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(date: headerDate, title: 'Agenda'),
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
                                  const Text(
                                    'Citas de hoy',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_right,
                                    size: 22,
                                    color: AppColors.textPrimary,
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
                                            : AppColors.textPrimary,
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
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    if (_isExpanded) ...[
                      if (appointments.isNotEmpty) ...[
                        for (var i = 0; i < appointments.length; i++) ...[
                          SwipeActionsRow(
                            key: ValueKey('agenda_home_${appointments[i].id}'),
                            groupTag: 'agenda_home',
                            onEdit: () => context.push(
                              '/agenda/detail',
                              extra: appointments[i],
                            ),
                            onDelete: () => _confirmDeleteAppointment(
                              context,
                              appointments[i],
                            ),
                            child: AppointmentCard(
                              appointment: appointments[i],
                              onTap: () => context.push(
                                '/agenda/detail',
                                extra: appointments[i],
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
                      ] else
                        const AgendaEmptyState(),
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
    Appointment appointment,
  ) async {
    final ok = await showConfirmDeleteDialog(
      context,
      title: 'Eliminar cita',
      body:
          '¿Seguro que deseas eliminar la cita "${appointment.title}"? '
          'Esta acción no se guardará hasta que exista persistencia.',
    );
    if (!ok || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_appointmentDeletePendingMessage)),
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
