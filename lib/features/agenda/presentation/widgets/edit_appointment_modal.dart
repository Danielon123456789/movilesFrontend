import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:agenda/core/network/api_exception.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../appointments/appointments_providers.dart';
import '../controllers/agenda_controller.dart';
import '../models/appointment_view_model.dart';
import '../providers/create_appointment_providers.dart';

class EditAppointmentModal extends ConsumerStatefulWidget {
  const EditAppointmentModal({
    super.key,
    required this.appointment,
  });

  final AppointmentViewModel appointment;

  @override
  ConsumerState<EditAppointmentModal> createState() =>
      _EditAppointmentModalState();
}

class _EditAppointmentModalState extends ConsumerState<EditAppointmentModal> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedPatientId;
  late String? _selectedTherapistId;
  late String? _selectedServiceId;

  late DateTime _selectedDateTime;

  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.appointment.patientId;
    _selectedTherapistId = widget.appointment.therapistId;
    _selectedServiceId = widget.appointment.serviceId;
    _selectedDateTime = widget.appointment.startDate.toLocal();
  }

  Future<void> _selectDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (!mounted || selectedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _invalidateRelevantAppointmentMonths(DateTime appointmentStart) {
    final agenda = ref.read(agendaControllerProvider);
    final anchors = <DateTime>{
      DateTime(appointmentStart.year, appointmentStart.month, 1),
      DateTime(
        widget.appointment.startDate.toLocal().year,
        widget.appointment.startDate.toLocal().month,
        1,
      ),
      DateTime(agenda.visibleMonth.year, agenda.visibleMonth.month, 1),
      DateTime(agenda.selectedDate.year, agenda.selectedDate.month, 1),
    };
    for (final a in anchors) {
      ref.invalidate(monthAppointmentsProvider(a));
    }
  }

  Future<void> _submit(CreateAppointmentDraftData draft) async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    int durationMinutes = 0;
    for (final s in draft.services) {
      if (s.id == _selectedServiceId) {
        durationMinutes = s.duration;
        break;
      }
    }

    final start = _selectedDateTime;
    final end = start.add(Duration(minutes: durationMinutes));

    setState(() => _submitting = true);

    try {
      await ref.read(appointmentsRepositoryProvider).updateAppointment(
            widget.appointment.id,
            patientId: _selectedPatientId,
            therapistId: _selectedTherapistId,
            serviceId: _selectedServiceId,
            startDate: start,
            endDate: end,
          );

      _invalidateRelevantAppointmentMonths(start);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita modificada correctamente.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  int? _durationForSelected(CreateAppointmentDraftData draft) {
    for (final s in draft.services) {
      if (s.id == _selectedServiceId) {
        return s.duration;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final draftAsync = ref.watch(createAppointmentDraftDataProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: draftAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'No se pudieron cargar los datos: $e',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.invalidate(createAppointmentDraftDataProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
          data: (draft) =>
              _buildForm(context, draft, textTheme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    CreateAppointmentDraftData draft,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final durationMinutes = _durationForSelected(draft);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Modificar cita',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _EditDropdownField(
              label: 'Paciente',
              hintText: draft.patients.isEmpty
                  ? 'Sin pacientes disponibles'
                  : 'Selecciona un paciente',
              value: _selectedPatientId,
              labelsByValue: {
                for (final p in draft.patients) p.id: p.name,
              },
              enabled: draft.patients.isNotEmpty,
              onChanged: (value) =>
                  setState(() => _selectedPatientId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _EditDropdownField(
              label: 'Terapeuta',
              hintText: draft.therapists.isEmpty
                  ? 'Sin terapeutas disponibles'
                  : 'Selecciona un terapeuta',
              value: _selectedTherapistId,
              labelsByValue: {
                for (final t in draft.therapists) t.id: t.name,
              },
              enabled: draft.therapists.isNotEmpty,
              onChanged: (value) =>
                  setState(() => _selectedTherapistId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _EditDropdownField(
              label: 'Tratamiento',
              hintText: draft.services.isEmpty
                  ? 'Sin tratamientos disponibles'
                  : 'Selecciona un tratamiento',
              value: _selectedServiceId,
              labelsByValue: {
                for (final s in draft.services) s.id: s.name,
              },
              enabled: draft.services.isNotEmpty,
              onChanged: (value) =>
                  setState(() => _selectedServiceId = value),
            ),
            if (_selectedServiceId != null && durationMinutes != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  'Duración: $durationMinutes minutos',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            _EditDateTimeField(
              dateTime: _selectedDateTime,
              onTap: _selectDateTime,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ||
                        draft.patients.isEmpty ||
                        draft.therapists.isEmpty ||
                        draft.services.isEmpty
                    ? null
                    : () => _submit(draft),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditDropdownField extends StatelessWidget {
  const _EditDropdownField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.labelsByValue,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final String? value;
  final Map<String, String> labelsByValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final entries = labelsByValue.entries.toList(growable: false)
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FormField<String>(
          key: ValueKey<String>(
            '${label}_${value ?? 'null'}_${entries.length}_$enabled',
          ),
          initialValue: value != null &&
                  entries.any((e) => e.key == value) &&
                  enabled
              ? value
              : null,
          enabled: enabled,
          validator: (v) {
            if (!enabled) return null;
            if (v == null || v.isEmpty) return 'Selecciona una opción';
            return null;
          },
          builder: (fieldState) {
            return InputDecorator(
              decoration: _editDropdownDecoration(context).copyWith(
                errorText: fieldState.errorText,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(hintText),
                  value: fieldState.value != null &&
                          entries.any((e) => e.key == fieldState.value)
                      ? fieldState.value
                      : null,
                  items: [
                    for (final e in entries)
                      DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                  ],
                  onChanged: enabled
                      ? (v) {
                          fieldState.didChange(v);
                          onChanged(v);
                        }
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

InputDecoration _editDropdownDecoration(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    filled: true,
    fillColor: colorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.primary),
    ),
  );
}

class _EditDateTimeField extends StatelessWidget {
  const _EditDateTimeField({
    required this.dateTime,
    required this.onTap,
  });

  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha y hora',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd/MM/yyyy - HH:mm', 'es').format(dateTime),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.event,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
