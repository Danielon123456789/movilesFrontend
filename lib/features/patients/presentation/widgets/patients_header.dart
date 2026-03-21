import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_screen_header.dart';

class PatientsHeader extends StatelessWidget {
  const PatientsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScreenHeader(
      date: 'MIÉRCOLES, 18 DE MARZO',
      title: 'Pacientes',
    );
  }
}

