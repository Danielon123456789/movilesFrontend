import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../controllers/agenda_controller.dart';
import '../widgets/agenda_calendar_section.dart';
import '../widgets/appointment_card.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agendaControllerProvider);
    final appointments = ref.watch(appointmentsForSelectedDateProvider);

    final headerDate = DateFormat('EEEE, d \'de\' MMMM', 'es')
        .format(state.selectedDate)
        .split(' ')
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              date: headerDate,
              title: 'Agenda',
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  AgendaCalendarSection(
                    onDayTap: (date) =>
                        context.push(Routes.agendaDayPath(date)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'Citas de hoy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (var i = 0; i < appointments.length; i++) ...[
                    AppointmentCard(appointment: appointments[i]),
                    if (i < appointments.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
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
        context.go(Routes.dashboard);
        return;
    }
  }
}
