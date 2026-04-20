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
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(
              date: 'DOMINGO, 15 DE MARZO',
              title: 'Dashboard',
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const _ProfileCard(),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsCard(
                    onConfigTap: () => context.push(Routes.settings),
                  ),
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
                  const _PendientesSection(),
                  const SizedBox(height: AppSpacing.md),
                  _LogoutCard(onTap: () => context.go(Routes.login)),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
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
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDEE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(),
          SizedBox(height: AppSpacing.lg),
          _InfoRow(icon: Icons.mail_outline, text: 'juan.perez@clinica.com'),
          SizedBox(height: AppSpacing.lg),
          _InfoRow(icon: Icons.phone_outlined, text: '+52 55 1234 5678'),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFF6479E8),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: const Text(
            'JP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dr. Juan Pérez',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF0F223A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDADDF0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF5E73E6),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Terapeuta',
                      style: TextStyle(
                        color: Color(0xFF5E73E6),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9AA3B2), size: 34),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF203552),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({this.onConfigTap});

  final VoidCallback? onConfigTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDEE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.account_circle_outlined,
            title: 'Profesionales',
            onTap: () => context.go(Routes.therapists),
          ),
          const Divider(height: 1),
          _SettingsItem(
            icon: Icons.shield_outlined,
            title: 'Configuración',
            onTap: onConfigTap,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9AA3B2), size: 34),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF203552),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF9AA3B2)),
          ],
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDEE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF4D4D), size: 28),
              SizedBox(width: 10),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color(0xFFFF4D4D),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
