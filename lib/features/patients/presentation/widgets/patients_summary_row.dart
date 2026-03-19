import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class PatientsSummaryRow extends StatelessWidget {
  const PatientsSummaryRow({
    super.key,
    required this.countLabel,
    required this.filterLabel,
    required this.onFilterTap,
  });

  final String countLabel;
  final String filterLabel;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    filterLabel,
                    style: textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
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

