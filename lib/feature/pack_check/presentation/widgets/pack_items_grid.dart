import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_item.dart';
import '../provider/pack_check_provider.dart';
import 'pack_item_card.dart';

/// Scrollable grid of all items in the active session.
///
/// Shows the full catalog in pack mode; shows only packed items in check mode.
class PackItemsGrid extends StatelessWidget {
  const PackItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PackCheckProvider>(
      builder: (context, provider, _) {
        final session = provider.activeSession;
        if (session == null) return const SizedBox.shrink();

        final items = provider.isCheckMode
            ? session.items.where((i) => i.isPacked).toList()
            : session.items;

        if (items.isEmpty) {
          return _EmptyState(isCheckMode: provider.isCheckMode);
        }

        return Scrollbar(
          thumbVisibility: true,
          radius: const Radius.circular(8),
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 0.82,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _ItemTile(item: items[i], provider: provider),
          ),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.provider});

  final PackItem item;
  final PackCheckProvider provider;

  @override
  Widget build(BuildContext context) {
    return PackItemCard(
      item: item,
      onTap: () => provider.togglePacked(item.id),
      onLongPress: item.isCustom
          ? () => _confirmDelete(context, provider, item)
          : null,
    );
  }

  void _confirmDelete(
    BuildContext context,
    PackCheckProvider provider,
    PackItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12102A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Remove "${item.name}"?',
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins_Bold'),
        ),
        content: Text(
          'This custom item will be permanently deleted.',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Poppins_Regular',
            fontSize: 13.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              provider.removeCustomItem(item.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFF43F5E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isCheckMode});

  final bool isCheckMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCheckMode ? Icons.check_circle_outline_rounded : Icons.inventory_2_outlined,
            size: 52.r,
            color: Colors.white24,
          ),
          SizedBox(height: 12.h),
          Text(
            isCheckMode
                ? 'Nothing packed yet.\nSwitch to Pack mode first.'
                : 'No items found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontFamily: 'Poppins_Regular',
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
