import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KurbaniAnimalPartTile extends StatelessWidget {
  const KurbaniAnimalPartTile({
    super.key,
    required this.part,
    required this.totalWeight,
    this.onDelete,
  });

  final KurbaniAnimalPartModel part;
  final double totalWeight;
  final VoidCallback? onDelete;

  static const Map<String, IconData> _partIcons = {
    'Meat': Icons.set_meal_rounded,
    'Bone': Icons.circle_outlined,
    'Liver': Icons.favorite_rounded,
    'Ribs': Icons.linear_scale_rounded,
    'Offal': Icons.blur_circular_rounded,
    'Head': Icons.tag_faces_rounded,
    'Feet': Icons.directions_walk_rounded,
  };

  static const Map<String, Color> _partColors = {
    'Meat': Color(0xFFEF4444),
    'Bone': Color(0xFF9CA3AF),
    'Liver': Color(0xFFEC4899),
    'Ribs': Color(0xFFF97316),
    'Offal': Color(0xFF8B5CF6),
    'Head': Color(0xFFF59E0B),
    'Feet': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = _partIcons[part.partName] ?? Icons.inventory_2_rounded;
    final color = _partColors[part.partName] ?? const Color(0xFF6D28D9);
    final pct = totalWeight > 0 ? (part.weightKg / totalWeight) * 100 : 0.0;
    final progress = totalWeight > 0 ? part.weightKg / totalWeight : 0.0;

    return Dismissible(
      key: Key(part.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22.r),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 20.r, color: color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.partName,
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (part.note != null)
                        Text(
                          part.note!,
                          style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 10.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${part.weightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
