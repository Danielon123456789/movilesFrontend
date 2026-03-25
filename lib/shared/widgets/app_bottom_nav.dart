import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.chipActiveFg,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          label: 'Pacientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Terapeutas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Dashboard',
        ),
      ],
    );
  }
}
