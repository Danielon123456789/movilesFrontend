import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class CreateAppointmentModal extends StatefulWidget {
  const CreateAppointmentModal({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  State<CreateAppointmentModal> createState() => _CreateAppointmentModalState();
}

class _CreateAppointmentModalState extends State<CreateAppointmentModal> {
  static const _pendingMessage = 'Este botón creará una nueva cita en la agenda.';

  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPatient;
  String? _selectedTherapist;
  String? _selectedTreatment;

  late DateTime _selectedDateTime;

  static const _patients = [
    'María López',
    'José Ramírez',
    'Ana Torres',
    'Carlos Méndez',
  ];

  static const _therapists = [
    'Daniel Hernández',
    'Sergio Gómez',
    'Roberto Gómez',
    'Carlos Rodríguez',
  ];

  static const _treatments = [
    'Terapia de lenguaje',
    'Terapia ocupacional',
    'Fisioterapia',
    'Psicología infantil',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDate;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
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
                'Crear cita',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalDropdownField(
                label: 'Paciente',
                hintText: 'Selecciona un paciente',
                value: _selectedPatient,
                items: _patients,
                onChanged: (value) => setState(() => _selectedPatient = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalDropdownField(
                label: 'Terapeuta',
                hintText: 'Selecciona un terapeuta',
                value: _selectedTherapist,
                items: _therapists,
                onChanged: (value) =>
                    setState(() => _selectedTherapist = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalDropdownField(
                label: 'Tratamiento',
                hintText: 'Selecciona un tratamiento',
                value: _selectedTreatment,
                items: _treatments,
                onChanged: (value) =>
                    setState(() => _selectedTreatment = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalDateTimeField(
                dateTime: _selectedDateTime,
                onTap: _selectDateTime,
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalInputField(
                label: 'Duración (minutos)',
                hintText: 'Ej. 60',
                controller: _durationController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              _ModalInputField(
                label: 'Notas',
                hintText: 'Notas de la cita',
                controller: _notesController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(_pendingMessage)),
                    );
                    Navigator.of(context).pop();
                  },
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
                  child: const Text('Crear cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (!mounted || selectedTime == null) {
      return;
    }

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
}

class _ModalDropdownField extends StatelessWidget {
  const _ModalDropdownField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hintText),
          decoration: _modalInputDecoration(context),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ModalDateTimeField extends StatelessWidget {
  const _ModalDateTimeField({
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

class _ModalInputField extends StatelessWidget {
  const _ModalInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: _modalInputDecoration(context, hintText: hintText),
        ),
      ],
    );
  }
}

InputDecoration _modalInputDecoration(
  BuildContext context, {
  String? hintText,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    hintText: hintText,
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