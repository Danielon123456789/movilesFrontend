import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import '../widgets/create_treatment_modal.dart';
import '../widgets/general_and_treatments_widgets.dart';

/// Pantalla dedicada a General (duración) y lista de tratamientos.
///
/// Header alineado a [PatientDetailScreen] (fondo blanco, chevron atrás centrado).
class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TreatmentsWhiteHeader(
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(settingsControllerProvider.notifier).fetchTreatments(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeneralDurationSection(
                      duration: state.defaultDuration,
                      onDurationChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          notifier.setDefaultDuration(parsed);
                        }
                      },
                    ),
                    const Divider(
                      height: AppSpacing.xl * 2,
                      color: AppColors.divider,
                    ),
                    TreatmentsManagementSection(
                      treatments: state.treatments,
                      onAdd: () => _openCreateTreatment(context, notifier),
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openCreateTreatment(
    BuildContext context,
    SettingsController notifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => CreateTreatmentModal(
        onSubmit: (name) {
          notifier.addTreatment(name);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

class _TreatmentsWhiteHeader extends StatelessWidget {
  const _TreatmentsWhiteHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: onBack,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Tratamientos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
