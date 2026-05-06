import 'dart:async';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(filteredPatientsProvider);
    final state = ref.watch(patientsControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const PatientsHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(patientsControllerProvider.notifier).fetchPatients(),
                child: SlidableAutoCloseBehavior(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                          color: Theme.of(context).colorScheme.surface,
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SwipeActionsRow(
                            key: ValueKey('patient_${p.id}'),
                            groupTag: 'patients_list',
                            onEdit: () => _showPatientSheet(
                              context,
                              ref,
                              editingPatient: p,
                            ),
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
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => _showPatientSheet(context, ref),
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
          '¿Seguro que deseas eliminar a "${patient.name}"? '
          'Se eliminará en el servidor y desaparecerá de tu lista.',
    );
    if (!ok || !context.mounted) return;

    await ref.read(patientsControllerProvider.notifier).removePatient(
      patient.id,
    );
    if (!context.mounted) return;
    final err = ref.read(patientsControllerProvider).errorMessage;
    final messenger = ScaffoldMessenger.of(context);
    if (err != null && err.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Paciente eliminado.')),
      );
    }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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

  static Future<void> _showPatientSheet(
    BuildContext context,
    WidgetRef ref, {
    Patient? editingPatient,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => CreatePatientModal(
        initialPatient: editingPatient,
        onSubmit: (data) {
          unawaited(
            _handlePatientSheetSubmit(
              context,
              ref,
              sheetContext,
              data,
              editingPatient,
            ),
          );
        },
      ),
    );
  }

  static Future<void> _handlePatientSheetSubmit(
    BuildContext rootContext,
    WidgetRef ref,
    BuildContext sheetContext,
    CreatePatientFormData data,
    Patient? editingPatient,
  ) async {
    final notifier = ref.read(patientsControllerProvider.notifier);
    if (editingPatient == null) {
      await notifier.addPatient(
        name: data.name,
        serviceLabel: data.service,
        email: data.tutorEmail,
        phoneNumber: data.tutorPhone,
      );
    } else {
      await notifier.updatePatient(
        editingPatient.id,
        name: data.name,
        email: data.tutorEmail,
        phoneNumber: data.tutorPhone,
        serviceLabel: data.service,
        active: data.active,
      );
    }

    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
    if (!rootContext.mounted) return;

    final err = ref.read(patientsControllerProvider).errorMessage;
    final messenger = ScaffoldMessenger.of(rootContext);
    if (err != null && err.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          editingPatient == null
              ? 'Paciente creado.'
              : 'Cambios guardados.',
        ),
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
