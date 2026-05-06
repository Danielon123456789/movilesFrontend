import 'package:agenda/models/user.model.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class TherapistCard extends StatelessWidget {
  const TherapistCard({
    super.key,
    required this.therapist,
    this.onTap,
    this.onMenuEdit,
    this.onMenuDelete,
  });

  final User therapist;
  final VoidCallback? onTap;

  /// Menú ⋮ superior derecha. Si ambos son null, no se muestra el botón.
  final VoidCallback? onMenuEdit;
  final VoidCallback? onMenuDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;

    // final hasMenu = onMenuEdit != null || onMenuDelete != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.fromBorderSide(
            BorderSide(color: colorScheme.outlineVariant),
          ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _TherapistIdentity(therapist: therapist)),
                // if (hasMenu)
                //   PopupMenuButton<String>(
                //     padding: const EdgeInsets.only(top: 8, right: 4),
                //     splashRadius: 26,
                //     iconSize: 28,
                //     icon: Icon(
                //       Icons.more_vert,
                //       color: AppColors.textMuted,
                //       size: 28,
                //     ),
                //     offset: const Offset(0, 6),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     color: AppColors.cardSurface,
                //     elevation: 2,
                //     itemBuilder: (context) => [
                //       if (onMenuEdit != null)
                //         const PopupMenuItem<String>(
                //           value: 'edit',
                //           child: Text('Editar'),
                //         ),
                //       if (onMenuDelete != null)
                //         PopupMenuItem<String>(
                //           value: 'delete',
                //           child: Text(
                //             'Eliminar',
                //             style: TextStyle(color: AppColors.error),
                //           ),
                //         ),
                //     ],
                //     onSelected: (value) {
                //       switch (value) {
                //         case 'edit':
                //           onMenuEdit?.call();
                //           break;
                //         case 'delete':
                //           onMenuDelete?.call();
                //           break;
                //       }
                //     },
                //   ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DataRow(icon: Icons.mail_outline, text: therapist.email),
            const SizedBox(height: AppSpacing.sm),
            _DataRow(icon: Icons.phone, text: therapist.phoneNumber ?? ''),
            const SizedBox(height: AppSpacing.sm),
            _DataRow(
              icon: Icons.person,
              text: therapist.role == Role.therapist
                  ? 'Terapeuta'
                  : 'Secretario(a)',
            ),
          ],
        ),
      ),
    );
  }
}

class _TherapistIdentity extends StatelessWidget {
  const _TherapistIdentity({required this.therapist});

  final User therapist;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primary,
          child: Text(
            therapist.name?[0] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                therapist.name ?? '',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon as IconData?, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// class _ScheduleSection extends StatelessWidget {
//   const _ScheduleSection({required this.schedule, required this.textTheme});

//   final List<TherapistSchedule> schedule;
//   final TextTheme textTheme;

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.access_time_outlined,
//               size: 18,
//               color: colorScheme.onSurfaceVariant,
//             ),
//             const SizedBox(width: AppSpacing.sm),
//             Text(
//               'Horario Laboral',
//               style: textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                   color: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppSpacing.sm),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: colorScheme.outlineVariant),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               for (var i = 0; i < schedule.length; i++) ...[
//                 if (i > 0)
//                   const Divider(height: 1, color: AppColors.subtleBorder),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppSpacing.md,
//                     vertical: AppSpacing.sm + 2,
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 40,
//                         child: Text(
//                           schedule[i].day,
//                           style: textTheme.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         schedule[i].timeRange,
//                         style: textTheme.bodyMedium?.copyWith(
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
