import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/patient.dart';

class CreatePatientFormData {
  const CreatePatientFormData({
    required this.name,
    required this.tutorPhone,
    required this.tutorEmail,
    required this.service,
  });

  final String name;
  final String tutorPhone;
  final String tutorEmail;
  final String service;
}

/// Bottom sheet compartido: creación ([initialPatient] null) o edición (no null).
class CreatePatientModal extends StatefulWidget {
  const CreatePatientModal({
    super.key,
    this.initialPatient,
    required this.onSubmit,
  });

  final Patient? initialPatient;
  final ValueChanged<CreatePatientFormData> onSubmit;

  @override
  State<CreatePatientModal> createState() => _CreatePatientModalState();
}

class _CreatePatientModalState extends State<CreatePatientModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorEmailController = TextEditingController();
  final _serviceController = TextEditingController();

  bool get _isEditing => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPatient;
    if (p != null) {
      _nameController.text = p.name;
      _serviceController.text = p.serviceLabel;
      _tutorPhoneController.text = p.phoneNumber ?? '';
      _tutorEmailController.text = p.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tutorPhoneController.dispose();
    _tutorEmailController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isEditing ? 'Editar paciente' : 'Nuevo paciente',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ModalInputField(
                  label: 'Nombre del paciente',
                  hintText: 'Ej. María González',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _ModalInputField(
                  label: 'Teléfono del tutor',
                  hintText: 'Ej. 33 1234 5678',
                  controller: _tutorPhoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) {
                      return 'Ingresa el teléfono del tutor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _ModalInputField(
                  label: 'Correo del tutor',
                  hintText: 'correo@ejemplo.com',
                  controller: _tutorEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Ingresa el correo del tutor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _ModalInputField(
                  label: 'Servicio / terapia necesaria',
                  hintText: 'Ej. Fisioterapia general',
                  controller: _serviceController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el servicio o terapia';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chipActiveFg,
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
                    child: Text(
                      _isEditing ? 'Guardar cambios' : 'Crear paciente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit(
      CreatePatientFormData(
        name: _nameController.text.trim(),
        tutorPhone: _tutorPhoneController.text.trim(),
        tutorEmail: _tutorEmailController.text.trim(),
        service: _serviceController.text.trim(),
      ),
    );
  }
}

class _ModalInputField extends StatelessWidget {
  const _ModalInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          decoration: _modalInputDecoration(context, hintText),
        ),
      ],
    );
  }
}

InputDecoration _modalInputDecoration(BuildContext context, String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.subtleBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.subtleBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.chipActiveFg, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
