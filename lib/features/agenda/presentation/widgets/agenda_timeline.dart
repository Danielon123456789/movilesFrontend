import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/swipe_actions_row.dart';
import '../../domain/entities/appointment.dart';

const int _startHour = 7;
const int _endHour = 24;

const double _hourHeightExpanded = 80.0;
const double _hourHeightCompact = 48.0;

class AgendaTimeline extends StatelessWidget {
  const AgendaTimeline({
    super.key,
    required this.showCurrentTimeIndicator,
    this.appointments = const [],
    this.onAppointmentTap,
    this.onAppointmentEdit,
    required this.onAppointmentDelete,
    this.agendaSwipeGroupTag = 'agenda_day_timeline',
  });

  final bool showCurrentTimeIndicator;
  final List<Appointment> appointments;
  final ValueChanged<Appointment>? onAppointmentTap;

  /// Callback del botón "Modificar" del swipe. Si es null se usa [onAppointmentTap].
  final ValueChanged<Appointment>? onAppointmentEdit;
  final ValueChanged<Appointment> onAppointmentDelete;

  /// Grupo opcional para [SlidableAutoCloseBehavior] desde la pantalla contenedora.
  final Object? agendaSwipeGroupTag;

  @override
  Widget build(BuildContext context) {
    final hourHeight = appointments.isNotEmpty
        ? _hourHeightExpanded
        : _hourHeightCompact;
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    final currentHourFraction = now.hour + now.minute / 60;
    final showCurrentTime =
        showCurrentTimeIndicator &&
        currentHourFraction >= _startHour &&
        currentHourFraction < _endHour;
    final currentTimeOffset = (currentHourFraction - _startHour) * hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = (_endHour - _startHour) * hourHeight;

        return SizedBox(
          height: contentHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Column(
                      children: [
                        for (var h = _startHour; h < _endHour; h++)
                          SizedBox(
                            height: hourHeight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                                right: AppSpacing.sm,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '${(h % 24).toString().padLeft(2, '0')}:00',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      size: Size(constraints.maxWidth - 56, contentHeight),
                      painter: _GridLinePainter(hourHeight: hourHeight),
                    ),
                  ),
                ],
              ),
              for (final appt in appointments)
                ..._buildAppointmentOverlay(appt, hourHeight),
              if (showCurrentTime)
                Positioned(
                  top: currentTimeOffset,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 46),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.currentTimeIndicator,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.currentTimeIndicator,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildAppointmentOverlay(Appointment appt, double hourHeight) {
    // TODO(timeline): el bloque siempre dibuja franja de 1h, ignorando la duración real.
    // El backend ya devuelve startDate y endDate correctos (la duración depende del servicio
    // elegido al crear la cita). Cuando se atienda este TODO, calcular altura real:
    //   final (startTime, endTime) = _parseTimeRange(appt.timeRange);
    //   final height = (endTime - startTime) * hourHeight;
    // Por ahora se mantiene el comportamiento legacy para no salir del scope de este PR.
    final (startTime, _) = _parseTimeRange(appt.timeRange);

    final slotStart = startTime.floor();
    final slotEnd = slotStart + 1;

    if (slotEnd <= _startHour || slotStart >= _endHour) return [];

    final clampedStart = slotStart.clamp(_startHour, _endHour - 1);
    final clampedEnd = (clampedStart + 1).clamp(_startHour + 1, _endHour);

    const inset = 2.0;
    final top = (clampedStart - _startHour) * hourHeight + inset;
    final height = hourHeight - inset * 2;

    final label =
        '${(clampedStart % 24).toString().padLeft(2, '0')}:00 - '
        '${(clampedEnd % 24).toString().padLeft(2, '0')}:00';

    return [
      Positioned(
        top: top,
        left: 60,
        right: 4,
        height: height,
        child: SwipeActionsRow(
          key: ValueKey('timeline_${appt.id}'),
          groupTag: agendaSwipeGroupTag,
          onEdit: () {
            final editCallback = onAppointmentEdit ?? onAppointmentTap;
            if (editCallback != null) editCallback(appt);
          },
          onDelete: () => onAppointmentDelete(appt),
          child: GestureDetector(
            onTap: onAppointmentTap != null
                ? () => onAppointmentTap!(appt)
                : null,
            behavior: HitTestBehavior.opaque,
            child: _TimelineAppointmentCard(
              appointment: appt,
              displayTimeRange: label,
            ),
          ),
        ),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

(double, double) _parseTimeRange(String timeRange) {
  final parts = timeRange.split(' - ');
  return (_parseHourMinute(parts[0].trim()), _parseHourMinute(parts[1].trim()));
}

double _parseHourMinute(String hm) {
  final parts = hm.split(':');
  return int.parse(parts[0]) + int.parse(parts[1]) / 60;
}

// ---------------------------------------------------------------------------
// Timeline appointment card (Figma style)
// ---------------------------------------------------------------------------

class _TimelineAppointmentCard extends StatelessWidget {
  const _TimelineAppointmentCard({
    required this.appointment,
    required this.displayTimeRange,
  });

  final Appointment appointment;
  final String displayTimeRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appointmentTintBg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Container(width: 4, color: AppColors.appointmentAccent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    appointment.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.appointmentAccent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayTimeRange,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid painter
// ---------------------------------------------------------------------------

class _GridLinePainter extends CustomPainter {
  _GridLinePainter({required this.hourHeight});

  final double hourHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.subtleBorder.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var h = 0; h <= _endHour - _startHour; h++) {
      final y = h * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinePainter oldDelegate) =>
      oldDelegate.hourHeight != hourHeight;
}
