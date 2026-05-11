import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_metric_card.dart';

String _fmt(AsyncValue<int> v) => v.when(
      data: (n) => '$n',
      loading: () => '--',
      error: (_, _) => '--',
    );

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAsync = ref.watch(monthAppointmentsCountProvider);
    final completedAsync = ref.watch(completedAppointmentsCountProvider);
    final activeCount = ref.watch(activePatientsCountProvider);
    final inactiveCount = ref.watch(inactivePatientsCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(title: 'Dashboard'),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  DashboardMetricCard(
                    label: 'Citas del Mes',
                    value: _fmt(monthAsync),
                    subtext: '${_fmt(completedAsync)} completadas',
                    icon: Icons.calendar_month,
                    iconColor: AppColors.chipActiveFg,
                    iconBgColor: AppColors.chipActiveBg,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DashboardMetricCard(
                    label: 'Pacientes de baja',
                    value: '$inactiveCount',
                    subtext: 'Total de pacientes',
                    icon: Icons.person_remove_outlined,
                    iconColor: AppColors.chipInactiveFg,
                    iconBgColor: AppColors.chipInactiveBg,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DashboardMetricCard(
                    label: 'Pacientes Activos',
                    value: '$activeCount',
                    subtext: 'Total de pacientes',
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.accentBlue,
                    iconBgColor: AppColors.accentBlue.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => context.push(Routes.settings),
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          tooltip: 'Configuración',
          shape: const CircleBorder(),
          child: const Icon(Icons.settings, color: Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.agenda);
        return;
      case 1:
        context.go(Routes.patients);
        return;
      case 2:
        context.go(Routes.therapists);
        return;
      case 3:
        context.go(Routes.dashboard);
        return;
    }
  }
}
