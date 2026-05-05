import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../app/theme/app_colors.dart';

class SwipeActionSpec {
  const SwipeActionSpec({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.flex = 1,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final int flex;
}

class SwipeActionsRow extends StatelessWidget {
  const SwipeActionsRow({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.trailingActions,
    this.groupTag,
    this.enabled = true,
    this.extentRatio,
  }) : assert(
         trailingActions != null || (onEdit != null && onDelete != null),
         'Pasa trailingActions o ambos callbacks onEdit y onDelete.',
       );

  final Widget child;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final List<SwipeActionSpec>? trailingActions;

  final Object? groupTag;
  final bool enabled;

  final double? extentRatio;

  static double _defaultExtentRatio(int actionCount) {
    switch (actionCount) {
      case <= 2:
        return 0.4;
      case 3:
        return 0.48;
      default:
        return 0.52;
    }
  }

  List<SwipeActionSpec> _resolvedSpecs() {
    final custom = trailingActions;
    if (custom != null) return custom;
    return [
      SwipeActionSpec(
        backgroundColor: AppColors.chipActiveFg,
        foregroundColor: Colors.white,
        icon: Icons.edit_outlined,
        label: 'Modificar',
        onPressed: onEdit!,
      ),
      SwipeActionSpec(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        icon: Icons.delete_outline,
        label: 'Eliminar',
        onPressed: onDelete!,
      ),
    ];
  }

  double _effectiveRatio(int count) {
    final o = extentRatio;
    if (o != null && o > 0 && o <= 1) return o;
    return _defaultExtentRatio(count).clamp(0.2, 0.52);
  }

  @override
  Widget build(BuildContext context) {
    final specs = _resolvedSpecs();
    final ratio = _effectiveRatio(specs.length);

    return Slidable(
      groupTag: groupTag,
      enabled: enabled,
      closeOnScroll: true,
      endActionPane: ActionPane(
        extentRatio: ratio,
        motion: const DrawerMotion(),
        children: [
          for (final spec in specs)
            CustomSlidableAction(
              flex: spec.flex,
              backgroundColor: spec.backgroundColor,
              foregroundColor: spec.foregroundColor,
              borderRadius: BorderRadius.zero,
              padding: EdgeInsets.zero,
              onPressed: (_) => spec.onPressed(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(spec.icon, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    spec.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: spec.foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
      child: child,
    );
  }
}
