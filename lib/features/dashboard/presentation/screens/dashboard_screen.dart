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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);

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
                    value: metrics.monthlyAppointments,
                    subtext: '${metrics.monthlyCompleted} completadas',
                    icon: Icons.calendar_month,
                    iconColor: AppColors.chipActiveFg,
                    iconBgColor: AppColors.chipActiveBg,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DashboardMetricCard(
                    label: 'Pacientes de baja',
                    value: metrics.inactivePatients,
                    subtext: 'Total de pacientes',
                    icon: Icons.person_remove_outlined,
                    iconColor: AppColors.chipInactiveFg,
                    iconBgColor: AppColors.chipInactiveBg,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DashboardMetricCard(
                    label: 'Pacientes Activos',
                    value: metrics.activePatients,
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

class _PendientesSection extends StatelessWidget {
  const _PendientesSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.22
                  : 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendientes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'No hay pendientes',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
