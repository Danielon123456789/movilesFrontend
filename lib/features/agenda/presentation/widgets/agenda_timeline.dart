import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

const int _startHour = 7;
const int _endHour = 16;
const double _hourHeight = 48;

class AgendaTimeline extends StatelessWidget {
  const AgendaTimeline({
    super.key,
    required this.showCurrentTimeIndicator,
  });

  final bool showCurrentTimeIndicator;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    final currentHourFraction = now.hour + now.minute / 60;
    final showCurrentTime = showCurrentTimeIndicator &&
        currentHourFraction >= _startHour &&
        currentHourFraction < _endHour;
    final currentTimeOffset =
        (currentHourFraction - _startHour) * _hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = (_endHour - _startHour) * _hourHeight;

        return SizedBox(
          height: contentHeight,
          child: Stack(
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
                              height: _hourHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                  right: AppSpacing.sm,
                                ),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')}:00',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                        size: Size(
                          constraints.maxWidth - 56,
                          contentHeight,
                        ),
                        painter: _GridLinePainter(),
                      ),
                    ),
                  ],
                ),
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
}

class _GridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.subtleBorder.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var h = 0; h <= _endHour - _startHour; h++) {
      final y = h * _hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
