import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class AgendaEmptyState extends StatelessWidget {
  const AgendaEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_cat.png',
            height: 120,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Por el momento no tienes citas',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
