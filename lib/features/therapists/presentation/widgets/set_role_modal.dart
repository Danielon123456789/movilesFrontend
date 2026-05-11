import 'package:agenda/app/theme/app_colors.dart';
import 'package:agenda/controllers/organization.controller.dart';
import 'package:agenda/models/user.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetRoleModal extends ConsumerStatefulWidget {
  const SetRoleModal({super.key});

  @override
  ConsumerState<SetRoleModal> createState() => _SetRoleModalState();
}

class _SetRoleModalState extends ConsumerState<SetRoleModal> {
  final _emailController = TextEditingController();
  String? selectedRole;
  final String secretary = 'Secretario',
      therapist = 'Terapeuta',
      none = 'Eliminar rol';

  @override
  Widget build(BuildContext context) {
    final roles = [secretary, therapist, none];
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP INDICATOR
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Modificar rol',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email del usuario',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              suffixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Rol', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              hintText: 'Selecciona un rol',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: roles.map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRole = value;
              });
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (selectedRole == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selecciona un rol')));
                  return;
                }
                final email = _emailController.text.trim();
                final String role;
                if (selectedRole == secretary) {
                  role = Role.secretary;
                } else if (selectedRole == therapist) {
                  role = Role.therapist;
                } else {
                  role = Role.none;
                }
                try {
                  await ref
                      .read(organizationControllerProvider)
                      .updateUserRole(email, role);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al asignar el rol')),
                  );
                }
                Navigator.pop(context);
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
              child: Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }
}
