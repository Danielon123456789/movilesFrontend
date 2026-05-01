import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';

/// Título de bloque compartido (también usado desde [SettingsScreen] en notificaciones).
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Duración predeterminada (antes en Configuración).
class GeneralDurationSection extends StatelessWidget {
  const GeneralDurationSection({
    super.key,
    required this.duration,
    required this.onDurationChanged,
  });

  final int duration;
  final ValueChanged<String> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle(
          icon: Icons.access_time_outlined,
          title: 'General',
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Duración predeterminada (min)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingsOutlinedTextField(
          initialValue: '$duration',
          onChanged: onDurationChanged,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

/// Lista editable de tratamientos (antes en Configuración).
class TreatmentsManagementSection extends StatelessWidget {
  const TreatmentsManagementSection({
    super.key,
    required this.treatments,
    required this.onAdd,
  });

  final List<Treatment> treatments;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 22,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Tratamientos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final t in treatments) ...[
          _TreatmentExpansionTile(treatment: t),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TreatmentExpansionTile extends StatelessWidget {
  const _TreatmentExpansionTile({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ExpansionTile(
        collapsedBackgroundColor: AppColors.cardSurface,
        backgroundColor: AppColors.cardSurface,
        shape: const Border(),
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: treatment.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${treatment.durationMinutes} min',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1, color: AppColors.subtleBorder),
          _tileOption(
            context,
            icon: Icons.edit_outlined,
            text: 'Editar',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Funcionalidad para editar tratamiento pendiente.',
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.subtleBorder),
          _tileOption(
            context,
            icon: Icons.delete_outline,
            text: 'Eliminar',
            color: AppColors.error,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Funcionalidad para eliminar tratamiento pendiente.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tileOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: optionColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: optionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo con borde usado en duración predeterminada y notificaciones.
class SettingsOutlinedTextField extends StatelessWidget {
  const SettingsOutlinedTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
      ),
    );
  }
}
