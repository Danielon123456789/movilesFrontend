import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../controllers/therapists_controller.dart';
import '../widgets/therapist_card.dart';

class TherapistsScreen extends ConsumerWidget {
  const TherapistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final therapists = ref.watch(filteredTherapistsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(
              date: 'MIÉRCOLES, 18 DE MARZO',
              title: 'Terapeutas',
            ),
            Expanded(
              child: ListView(
                children: [
                  _SearchField(
                    onChanged: (value) => ref
                        .read(therapistsControllerProvider.notifier)
                        .setQuery(value),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      '${therapists.length} terapeutas',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final t in therapists) TherapistCard(therapist: t),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: navigate to create therapist
          },
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.agenda);
      case 1:
        context.go(Routes.patients);
      case 2:
        context.go(Routes.therapists);
      case 3:
        context.go(Routes.dashboard);
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar terapeuta...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.cardSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.subtleBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.subtleBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
