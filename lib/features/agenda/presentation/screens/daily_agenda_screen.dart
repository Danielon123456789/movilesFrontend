import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../controllers/agenda_controller.dart';
import '../widgets/agenda_day_detail_header.dart';
import '../widgets/agenda_timeline.dart';
import '../widgets/agenda_week_strip.dart';
import '../widgets/create_appointment_modal.dart';

class DailyAgendaScreen extends ConsumerStatefulWidget {
  const DailyAgendaScreen({
    super.key,
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  ConsumerState<DailyAgendaScreen> createState() => _DailyAgendaScreenState();
}

class _DailyAgendaScreenState extends ConsumerState<DailyAgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agendaControllerProvider.notifier).selectDate(widget.selectedDate);
    });
  }

  @override
  void didUpdateWidget(covariant DailyAgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      ref.read(agendaControllerProvider.notifier).selectDate(widget.selectedDate);
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
        .replaceFirstMapped(
          RegExp(r'^.'),
          (m) => m.group(0)!.toUpperCase(),
        );

    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final dayTitle = isToday
        ? 'Hoy'
        : DateFormat('EEEE d', 'es').format(selectedDate).split(' ').map((s) {
            return s[0].toUpperCase() + s.substring(1).toLowerCase();
          }).join(' ');

    final textTheme = Theme.of(context).textTheme;
    final appointments = ref.watch(appointmentsForSelectedDateProvider);

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
                  appointments: appointments,
                  onAppointmentTap: (appt) => context.push(
                    '/agenda/detail',
                    extra: appt,
                  ),
                ),
              ],
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
