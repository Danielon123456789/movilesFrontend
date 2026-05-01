import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/dialogs/confirm_delete_dialog.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/swipe_actions_row.dart';
import '../../domain/entities/patient.dart';
import '../controllers/patients_controller.dart';
import '../widgets/patient_card.dart';
import '../widgets/create_patient_modal.dart';
import '../widgets/patients_header.dart';
import '../widgets/patients_search_field.dart';
import '../widgets/patients_summary_row.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  static const _pendingMessage =
      'Este botón guardará el nuevo paciente en la base de datos.';

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
              child: SlidableAutoCloseBehavior(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Material(
                          color: AppColors.cardSurface,
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: AppColors.subtleBorder,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SwipeActionsRow(
                            key: ValueKey('patient_${p.id}'),
                            groupTag: 'patients_list',
                            onEdit: () =>
                                context.push('/patients/detail', extra: p),
                            onDelete: () =>
                                _confirmRemovePatient(context, ref, p),
                            child: PatientCard(
                              showCardChrome: false,
                              patient: p,
                              onTap: () =>
                                  context.push('/patients/detail', extra: p),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => _showCreatePatientModal(context, ref),
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static Future<void> _confirmRemovePatient(
    BuildContext context,
    WidgetRef ref,
    Patient patient,
  ) async {
    final ok = await showConfirmDeleteDialog(
      context,
      title: 'Eliminar paciente',
      body:
          '¿Seguro que deseas eliminar de la lista a "${patient.name}"? '
          'Solo se quitará de la vista local hasta que exista servidor.',
    );
    if (!ok || !context.mounted) return;

    ref.read(patientsControllerProvider.notifier).removePatient(patient.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paciente eliminado de la lista actual.')),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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

  static Future<void> _showCreatePatientModal(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => CreatePatientModal(
        onSubmit: (data) {
          ref
              .read(patientsControllerProvider.notifier)
              .addPatient(name: data.name, serviceLabel: data.service);

          Navigator.of(sheetContext).pop();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(_pendingMessage)));
        },
      ),
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
