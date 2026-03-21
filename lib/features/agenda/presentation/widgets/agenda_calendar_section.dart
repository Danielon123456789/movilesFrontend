import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../controllers/agenda_controller.dart';
import 'agenda_day_cell.dart';

const List<String> _weekdayLabels = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];

class AgendaCalendarSection extends ConsumerWidget {
  const AgendaCalendarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agendaControllerProvider);
    final notifier = ref.read(agendaControllerProvider.notifier);
    final cells = visibleGridCells(state.visibleMonth);
    final daysWithAppointments = ref.watch(daysWithAppointmentsProvider);

    final dateLabel = DateFormat('d MMM yy EEEE', 'es')
        .format(state.selectedDate)
        .split(' ')
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');

    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => notifier.previousMonth(),
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                    ),
                  ),
                  IconButton(
                    onPressed: () => notifier.nextMonth(),
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              for (var i = 0; i < cells.length; i++)
                AgendaDayCell(
                  day: cells[i],
                  isSelected: cells[i] != null &&
                      state.selectedDate.year == state.visibleMonth.year &&
                      state.selectedDate.month == state.visibleMonth.month &&
                      state.selectedDate.day == cells[i],
                  hasAppointments: cells[i] != null &&
                      daysWithAppointments.contains(cells[i]),
                  onTap: cells[i] != null
                      ? () => notifier.selectDate(
                            DateTime(
                              state.visibleMonth.year,
                              state.visibleMonth.month,
                              cells[i]!,
                            ),
                          )
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
