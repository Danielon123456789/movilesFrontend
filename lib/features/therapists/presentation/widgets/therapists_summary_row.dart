import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// Misma distribución que [PatientsSummaryRow]: conteo a la izquierda,
/// acción secundaria a la derecha.
class TherapistsSummaryRow extends StatelessWidget {
  const TherapistsSummaryRow({
    super.key,
    required this.countLabel,
    required this.onTreatmentsTap,
  });

  final String countLabel;
  final VoidCallback onTreatmentsTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              countLabel,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: onTreatmentsTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    'Tratamientos',
                    style: textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.medical_services_outlined,
                    size: 18,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
