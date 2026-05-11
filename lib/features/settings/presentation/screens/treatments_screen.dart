import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/features/services/domain/entities/service.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import '../widgets/create_treatment_modal.dart';
import '../widgets/edit_treatment_modal.dart';
import '../widgets/general_and_treatments_widgets.dart';

/// Pantalla dedicada a General (duración) y lista de tratamientos.
///
/// Header alineado a [PatientDetailScreen] (fondo blanco, chevron atrás centrado).
class TreatmentsScreen extends ConsumerStatefulWidget {
  const TreatmentsScreen({super.key});

  @override
  ConsumerState<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends ConsumerState<TreatmentsScreen> {
  var _loadingTreatments = true;

  Future<void> _loadTreatments() async {
    setState(() => _loadingTreatments = true);
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .refreshTreatmentsServices();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTreatments = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTreatments();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onRefresh: _loadTreatments,
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
                      if (_loadingTreatments &&
                          state.treatments.isEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ] else
                        TreatmentsManagementSection(
                          services: state.treatments,
                          onAdd: () => _openCreateTreatment(context, notifier),
                          onEdit: (s) =>
                              _openEditTreatment(context, notifier, s),
                          onDelete: (s) =>
                              _confirmDeleteTreatment(context, notifier, s),
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

  Future<void> _openCreateTreatment(
    BuildContext context,
    SettingsController notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => CreateTreatmentModal(
        onSubmit: (name, duration) async {
          try {
            await notifier.addTreatment(name, duration);
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          } on ApiException catch (e) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(content: Text(e.message)),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _openEditTreatment(
    BuildContext context,
    SettingsController notifier,
    Service service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => EditTreatmentModal(
        initialName: service.name,
        initialDuration: service.duration,
        onSubmit: (name, duration) async {
          try {
            await notifier.editTreatment(
              service.id,
              name: name,
              duration: duration,
            );
            if (!context.mounted) return;
            Navigator.of(sheetContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tratamiento actualizado')),
            );
          } on ApiException catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message)),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteTreatment(
    BuildContext context,
    SettingsController notifier,
    Service service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tratamiento'),
        content: Text(
          '¿Eliminar "${service.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await notifier.removeTreatment(service.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tratamiento eliminado')),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final msg = e.message.contains('existing appointments')
          ? 'No se puede eliminar: este tratamiento tiene citas asociadas'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
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
