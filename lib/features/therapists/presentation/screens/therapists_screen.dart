import 'package:agenda/app/theme/app_colors.dart';
import 'package:agenda/controllers/user.controller.dart';
import 'package:agenda/features/therapists/presentation/widgets/set_role_modal.dart';
import 'package:agenda/models/user.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../widgets/therapist_card.dart';
import '../widgets/therapists_summary_row.dart';

class UserFilter {
  final String query;
  final String role;

  const UserFilter({this.query = '', this.role = ''});

  UserFilter copyWith({String? query, String? role}) {
    return UserFilter(query: query ?? this.query, role: role ?? this.role);
  }
}

class UserFilterNotifier extends Notifier<UserFilter> {
  @override
  UserFilter build() {
    return const UserFilter();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setRole(String role) {
    state = state.copyWith(role: role);
  }
}

final usersProvider = FutureProvider<List<User>>((ref) async {
  final filter = ref.watch(userFilterProvider);
  final controller = ref.watch(userControllerProvider);
  return controller.getByQuery(query: filter.query, role: filter.role);
});

final userFilterProvider = NotifierProvider<UserFilterNotifier, UserFilter>(
  UserFilterNotifier.new,
);

class TherapistsScreen extends ConsumerWidget {
  const TherapistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(title: 'Organización'),
            _SearchField(
              onChanged: (value) {
                ref.read(userFilterProvider.notifier).setQuery(value);
              },
            ),
            Container(
              child: usersAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (users) => Expanded(
                  child: Column(
                    children: [
                      TherapistsSummaryRow(
                        countLabel: '${users.length} usuarios',
                        onTreatmentsTap: () =>
                            context.push(Routes.therapistsTreatments),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: AppSpacing.sm,
                            children: [Text('Filtro'), Icon(Icons.tune)],
                          ),
                          onTap: () => _showFilterSheet(context, ref),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(usersProvider);
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return TherapistCard(therapist: user);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 8),
      //   child: FloatingActionButton(
      //     onPressed: () => _showTherapistFormModal(context, ref),
      //     backgroundColor: AppColors.accentBlue,
      //     elevation: 4,
      //     shape: const CircleBorder(),
      //     child: const Icon(Icons.add, color: Colors.white),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar: AppBottomNav(
      //   currentIndex: 2,
      //   onTap: (index) => _onNavTap(context, index),
      // ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => showSetRoleModal(context),
          backgroundColor: AppColors.accentBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  static Future<void> showSetRoleModal(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SetRoleModal(),
    );
  }

  // static Future<void> _confirmRemoveTherapist(
  //   BuildContext context,
  //   WidgetRef ref,
  //   User therapist,
  // ) async {
  //   final ok = await showConfirmDeleteDialog(
  //     context,
  //     title: 'Eliminar terapeuta',
  //     body:
  //         '¿Seguro que deseas eliminar de la lista a "${therapist.name}"? '
  //         'Solo se quitará de la vista actual hasta integrar servidor.',
  //   );
  //   if (!ok || !context.mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Terapeuta eliminado de la lista actual.')),
  //   );
  // }

  // Future<void> _showTherapistFormModal(BuildContext context, WidgetRef ref, [Therapist? therapist]) {
  //   return showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Theme.of(context).colorScheme.surface,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (sheetContext) => TherapistFormModal(
  //       initialData: therapist,
  //       onSubmit: (data) {
  //         Navigator.of(sheetContext).pop();
  //         if (therapist == null) {
  //           ref.read(therapistsControllerProvider.notifier).addTherapist(
  //                 name: data.name,
  //                 email: data.email.isNotEmpty ? data.email : null,
  //                 phoneNumber: data.phone.isNotEmpty ? data.phone : null,
  //                 specialty: data.specialty.isNotEmpty ? data.specialty : null,
  //               );
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Terapeuta creado con éxito.')),
  //           );
  //         } else {
  //           ref.read(therapistsControllerProvid.notifier).updateTherapist(
  //                 therapist.id,
  //                 name: data.name,
  //                 email: data.email.isNotEmpty ? data.email : null,
  //                 phoneNumber: data.phone.isNotEmpty ? data.phone : null,
  //                 specialty: data.specialty.isNotEmpty ? data.specialty : null,
  //               );
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Terapeuta actualizado con éxito.')),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

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
          hintText: 'Buscar usuario...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
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

Future<void> _showFilterSheet(BuildContext context, WidgetRef ref) {
  String current = ref.read(userFilterProvider).role;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtro',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterTile(
                label: 'Todos',
                selected: current == '',
                onTap: () {
                  ref.read(userFilterProvider.notifier).setRole('');
                  Navigator.of(context).pop();
                },
              ),
              _FilterTile(
                label: 'Terapeutas',
                selected: current == Role.therapist,
                onTap: () {
                  ref.read(userFilterProvider.notifier).setRole(Role.therapist);
                  Navigator.of(context).pop();
                },
              ),
              _FilterTile(
                label: 'Secretarios',
                selected: current == Role.secretary,
                onTap: () {
                  ref.read(userFilterProvider.notifier).setRole(Role.secretary);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
