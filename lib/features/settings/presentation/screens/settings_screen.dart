import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DarkModeSection(),
                    const Divider(height: AppSpacing.xl * 2, color: AppColors.divider),
                    _GeneralSection(
                      duration: state.defaultDuration,
                      onDurationChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) notifier.setDefaultDuration(parsed);
                      },
                    ),
                    const Divider(height: AppSpacing.xl * 2, color: AppColors.divider),
                    _NotificationsSection(
                      enabled: state.notificationsEnabled,
                      onToggle: notifier.toggleNotifications,
                      reminderHours: state.reminderHours,
                      onReminderChanged: notifier.setReminderHours,
                    ),
                    const Divider(height: AppSpacing.xl * 2, color: AppColors.divider),
                    _TreatmentsSection(treatments: state.treatments),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accentBlue,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: onBack,
              color: Colors.white,
            ),
          ),
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

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

class _DarkModeSection extends StatelessWidget {
  const _DarkModeSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.dark_mode_outlined, size: 22, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo oscuro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Cambiar apariencia de la app',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: false,
          onChanged: (_) {},
          activeColor: AppColors.accentBlue,
        ),
      ],
    );
  }
}

class _GeneralSection extends StatelessWidget {
  const _GeneralSection({
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
        const _SectionTitle(icon: Icons.access_time_outlined, title: 'General'),
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
        _StyledTextField(
          initialValue: '$duration',
          onChanged: onDurationChanged,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({
    required this.enabled,
    required this.onToggle,
    required this.reminderHours,
    required this.onReminderChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final String reminderHours;
  final ValueChanged<String> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.notifications_none_outlined,
          title: 'Notificaciones',
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habilitar notificaciones',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recordatorios de citas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: AppColors.accentBlue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Recordar antes de (horas)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _StyledTextField(
          initialValue: reminderHours,
          onChanged: onReminderChanged,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _TreatmentsSection extends StatelessWidget {
  const _TreatmentsSection({required this.treatments});

  final List<Treatment> treatments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medical_services_outlined,
                size: 22, color: AppColors.textPrimary),
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
            GestureDetector(
              onTap: () {
                // TODO: open create treatment flow
              },
              child: const Text(
                '+ Nuevo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final t in treatments) ...[
          _TreatmentTile(treatment: t),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TreatmentTile extends StatelessWidget {
  const _TreatmentTile({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.subtleBorder),
        ),
      ),
      child: Row(
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
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
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
