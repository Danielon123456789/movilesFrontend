import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../appointments/appointments_providers.dart';
import '../../domain/entities/appointment.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  const AppointmentDetailScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  late String _notes;

  @override
  void initState() {
    super.initState();
    _notes = widget.appointment.notes;
  }

  Future<void> _openNotesDialog() async {
    final controller = TextEditingController(text: _notes);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => _NotesDialog(controller: controller),
    );
    if (saved == null || !mounted) return;

    try {
      await ref
          .read(appointmentsRepositoryProvider)
          .updateAppointmentNotes(widget.appointment.id, saved);
      setState(() => _notes = saved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avances guardados correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    final formattedDate = DateFormat("EEEE, d 'De' MMMM 'De' yyyy", 'es')
        .format(appointment.date)
        .split(' ')
        .map((w) => w.length > 2
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : w)
        .join(' ');

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
                    _PatientSection(
                      patientName: appointment.title,
                      therapistName: appointment.therapist,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    const SizedBox(height: AppSpacing.lg),
                    _InfoRow(
                      imagePath: 'assets/images/icon_calendar.png',
                      label: 'FECHA DE LA CITA',
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Horario : ${appointment.timeRange}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _InfoRow(
                      imagePath: 'assets/images/icon_treatment.png',
                      label: 'AVANCES DE SESIÓN',
                      children: [
                        _notes.trim().isEmpty
                            ? const Text(
                                'Sin avances registrados aún.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Text(
                                _notes,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                  height: 1.5,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _BottomButton(onPressed: _openNotesDialog),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _NotesDialog extends StatelessWidget {
  const _NotesDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text(
        'Avances de sesión',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: controller,
        maxLines: 6,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Escribe los avances de esta sesión…',
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

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
            'Detalle de Cita',
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

class _PatientSection extends StatelessWidget {
  const _PatientSection({
    required this.patientName,
    required this.therapistName,
  });

  final String patientName;
  final String therapistName;

  @override
  Widget build(BuildContext context) {
    final trimmedTherapist = therapistName.trim();
    final subtitle = trimmedTherapist.isEmpty
        ? 'Paciente programado para el terapeuta asignado.'
        : 'Paciente programado para $trimmedTherapist.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOMBRE DEL PACIENTE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          patientName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.imagePath,
    required this.label,
    required this.children,
  });

  final String imagePath;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
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
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Agregar avances de sesión'),
        ),
      ),
    );
  }
}
