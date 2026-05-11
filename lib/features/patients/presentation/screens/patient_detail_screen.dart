import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../appointments/appointments_providers.dart';
import '../../../appointments/domain/entities/appointment.dart' as api;
import '../../domain/entities/patient.dart';

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(
      patientAppointmentsProvider(patient.id),
    );

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
                    _LabelValue(label: 'NOMBRE DEL PACIENTE', value: patient.name),
                    if (patient.email != null && patient.email!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _LabelValue(label: 'CORREO', value: patient.email!),
                    ],
                    if (patient.phoneNumber != null && patient.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _LabelValue(label: 'TELÉFONO', value: patient.phoneNumber!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: AppSpacing.lg),
                    appointmentsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No se pudo cargar el historial.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      data: (appointments) => _ProgressSection(
                        appointments: appointments,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

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
            'Detalles de paciente',
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

// ---------------------------------------------------------------------------
// Label + value pair
// ---------------------------------------------------------------------------

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress / Avances section
// ---------------------------------------------------------------------------

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.appointments});

  final List<api.Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    // Sort descending by start date (most recent first)
    final sorted = [...appointments]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    // Only show appointments that have notes
    final withNotes = sorted.where((a) => a.notes.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCanvas,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Avances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${sorted.length} cita${sorted.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (withNotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Sin avances registrados todavía.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            for (var i = 0; i < withNotes.length; i++) ...[
              _ProgressCard(
                appointment: withNotes[i],
                sessionNumber: sorted.length - sorted.indexOf(withNotes[i]),
              ),
              if (i < withNotes.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.appointment,
    required this.sessionNumber,
  });

  final api.Appointment appointment;
  final int sessionNumber;

  @override
  Widget build(BuildContext context) {
    final localDate = appointment.startDate.toLocal();
    final dateLabel = DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(localDate);
    final timeLabel =
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.subtleBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesión $sessionNumber',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            appointment.notes,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$dateLabel · $timeLabel',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }
}
