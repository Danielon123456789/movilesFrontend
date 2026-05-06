import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/patient.dart';
import 'patient_status_chip.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    this.onTap,
    this.showCardChrome = true,
  });

  final Patient patient;
  final VoidCallback? onTap;

  /// Si es false, solo se pinta el contenido para incrustarlo en un contenedor exterior
  /// ([Material] + [Slidable]) que define borde, sombra y recorte redondeado.
  final bool showCardChrome;

  static const double _chromeRadius = 18;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = patient.isActive
        ? AppColors.chipActiveFg
        : AppColors.chipInactiveFg;

    final content = Row(
      children: [
        Container(
          width: 6,
          height: 92,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(_chromeRadius),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        patient.email ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        patient.phoneNumber ?? '',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PatientStatusChip(isActive: patient.isActive),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: showCardChrome
          ? Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(_chromeRadius),
                border: Border.fromBorderSide(
                  BorderSide(color: colorScheme.outlineVariant),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.22
                          : 0.06,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: content,
            )
          : ColoredBox(color: Colors.transparent, child: content),
    );
  }
}
