import 'package:flutter/material.dart';

import 'package:agenda/features/services/domain/entities/service.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Color estable para el punto del listado (solo presentación).
Color treatmentSwatchColor(Service service) => Colors
    .primaries[service.id.hashCode.abs() % Colors.primaries.length];

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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.onSurface),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
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
        Text(
          'Duración predeterminada (min)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

/// Lista de tratamientos (servicios backend). Editar / eliminar requieren API aún no disponible.
class TreatmentsManagementSection extends StatelessWidget {
  const TreatmentsManagementSection({
    super.key,
    required this.services,
    required this.onAdd,
  });

  final List<Service> services;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Tratamientos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
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
        for (final service in services) ...[
          _TreatmentExpansionTile(service: service),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TreatmentExpansionTile extends StatelessWidget {
  const _TreatmentExpansionTile({required this.service});

  final Service service;

  void _showServerPending(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Esta acción estará disponible cuando exista soporte en el servidor.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ExpansionTile(
        collapsedBackgroundColor: colorScheme.surface,
        backgroundColor: colorScheme.surface,
        shape: const Border(),
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: treatmentSwatchColor(service),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.duration} min',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Divider(height: 1, color: colorScheme.outlineVariant),
          _tileOption(
            context,
            icon: Icons.edit_outlined,
            text: 'Editar',
            onTap: () => _showServerPending(context),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _tileOption(
            context,
            icon: Icons.delete_outline,
            text: 'Eliminar',
            color: AppColors.error,
            onTap: () => _showServerPending(context),
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
    final optionColor = color ?? Theme.of(context).colorScheme.onSurface;
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
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
