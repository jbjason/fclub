import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/home/presentation/widgets/home_widgets/home_club_stats_card.dart';
import 'package:fclub/feature/home/presentation/widgets/home_widgets/home_feature_grid.dart';
import 'package:fclub/feature/home/presentation/widgets/home_widgets/home_header.dart';
import 'package:fclub/feature/home/presentation/widgets/home_widgets/home_locker_stat_card.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load dashboard sources before the user visits their feature screens.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final contacts = context.read<GlobalContactsProvider>();
      final club = context.read<ClubProvider>();
      final locker = context.read<LockerProvider>();
      await contacts.loadContacts();
      await club.initialize();
      await locker.seedDemoData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // ── Scrollable body ────────────────────────────────────────────────────
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Brand hero ──────────────────────────────────────
                const HomeHeader(),
                SizedBox(height: 24.h),
                // ── Highlights section ──────────────────────────────
                _SectionTitle(label: 'highlights'.tr()),
                SizedBox(height: 12.h),
                const HomeClubStatsCard(),
                SizedBox(height: 12.h),
                const HomeLockerStatCard(),
                SizedBox(height: 24.h),
                // ── Quick Access section ────────────────────────────
                _SectionTitle(label: 'quick_access'.tr()),
                SizedBox(height: 12.h),
                // ── Feature cards ───────────────────────────────────
                const HomeFeatureGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ─────────────────────────────────────────────────────

/// A small section divider with a violet accent bar on the left and
/// a muted label on the right. Used to visually group card sections.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Violet accent bar
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: MyColor.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
