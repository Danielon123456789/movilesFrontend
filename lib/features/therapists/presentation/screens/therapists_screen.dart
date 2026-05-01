import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/dialogs/confirm_delete_dialog.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../domain/entities/therapist.dart';
import '../controllers/therapists_controller.dart';
import '../widgets/therapist_card.dart';
import '../widgets/create_therapist_modal.dart';
import '../widgets/therapists_summary_row.dart';

class TherapistsScreen extends ConsumerWidget {
  const TherapistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final therapists = ref.watch(filteredTherapistsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(
              date: 'MIÉRCOLES, 18 DE MARZO',
              title: 'Terapeutas',
            ),
            Expanded(
              child: ListView(
                children: [
                  _SearchField(
                    onChanged: (value) => ref
                        .read(therapistsControllerProvider.notifier)
                        .setQuery(value),
                  ),
                  TherapistsSummaryRow(
                    countLabel: '${therapists.length} terapeutas',
                    onTreatmentsTap: () =>
                        context.push(Routes.therapistsTreatments),
                  ),
                  for (final t in therapists)
                    TherapistCard(
                      therapist: t,
                      onMenuEdit: () {
                        debugPrint(
                          '[TherapistCard] editar id=${t.id} nombre=${t.name}',
                        );
                      },
                      onMenuDelete: () =>
                          _confirmRemoveTherapist(context, ref, t),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => _showCreateTherapistModal(context),
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static Future<void> _confirmRemoveTherapist(
    BuildContext context,
    WidgetRef ref,
    Therapist therapist,
  ) async {
    final ok = await showConfirmDeleteDialog(
      context,
      title: 'Eliminar terapeuta',
      body:
          '¿Seguro que deseas eliminar de la lista a "${therapist.name}"? '
          'Solo se quitará de la vista actual hasta integrar servidor.',
    );
    if (!ok || !context.mounted) return;

    ref
        .read(therapistsControllerProvider.notifier)
        .removeTherapist(therapist.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terapeuta eliminado de la lista actual.')),
    );
  }

  Future<void> _showCreateTherapistModal(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => CreateTherapistModal(
        onSubmit: (data) {
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este botón creará un terapeuta')),
          );
        },
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
        context.go(Routes.therapists);
      case 3:
        context.go(Routes.dashboard);
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar terapeuta...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.cardSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.subtleBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.subtleBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
