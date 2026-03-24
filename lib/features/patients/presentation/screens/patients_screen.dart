import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../controllers/patients_controller.dart';
import '../widgets/patient_card.dart';
import '../widgets/patients_header.dart';
import '../widgets/patients_search_field.dart';
import '../widgets/patients_summary_row.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(filteredPatientsProvider);
    final state = ref.watch(patientsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const PatientsHeader(),
            Expanded(
              child: ListView(
                children: [
                  PatientsSearchField(
                    onChanged: (value) => ref
                        .read(patientsControllerProvider.notifier)
                        .setQuery(value),
                  ),
                  PatientsSummaryRow(
                    countLabel: '${patients.length} pacientes',
                    filterLabel: _filterLabel(state.filter),
                    onFilterTap: () => _showFilterSheet(context, ref),
                  ),
                  for (final p in patients)
                    PatientCard(
                      patient: p,
                      onTap: () => context.push('/patients/detail', extra: p),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
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
        context.go(Routes.dashboard);
    }
  }

  static String _filterLabel(PatientsFilter filter) {
    return switch (filter) {
      PatientsFilter.all => 'Todos',
      PatientsFilter.active => 'Activos',
      PatientsFilter.inactive => 'Baja',
    };
  }

  static Future<void> _showFilterSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(patientsControllerProvider).filter;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtro',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                _FilterTile(
                  label: 'Todos',
                  selected: current == PatientsFilter.all,
                  onTap: () {
                    ref
                        .read(patientsControllerProvider.notifier)
                        .setFilter(PatientsFilter.all);
                    Navigator.of(context).pop();
                  },
                ),
                _FilterTile(
                  label: 'Activos',
                  selected: current == PatientsFilter.active,
                  onTap: () {
                    ref
                        .read(patientsControllerProvider.notifier)
                        .setFilter(PatientsFilter.active);
                    Navigator.of(context).pop();
                  },
                ),
                _FilterTile(
                  label: 'Baja',
                  selected: current == PatientsFilter.inactive,
                  onTap: () {
                    ref
                        .read(patientsControllerProvider.notifier)
                        .setFilter(PatientsFilter.inactive);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

