import 'dart:async';

import 'package:agenda/models/patient.model.dart';
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
import '../controllers/patients_controller.dart';
import '../widgets/patient_card.dart';
import '../widgets/create_patient_modal.dart';
import '../widgets/patients_header.dart';
import '../widgets/patients_search_field.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(filteredPatientsProvider);

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

    await ref
        .read(patientsControllerProvider.notifier)
        .removePatient(patient.id);
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

  static Future<void> _showPatientSheet(
    BuildContext context,
    WidgetRef ref, {
    Patient? editingPatient,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
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
      await notifier.addPatient(name: data.name);
    } else {
      await notifier.updatePatient(
        editingPatient.id,
        name: data.name,
        email: data.tutorEmail,
        phoneNumber: data.tutorPhone,
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
          editingPatient == null ? 'Paciente creado.' : 'Cambios guardados.',
        ),
      ),
    );
  }
}
