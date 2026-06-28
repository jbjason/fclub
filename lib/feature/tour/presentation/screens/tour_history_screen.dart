import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_active_session_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_empty_history_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history_app_bar.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_new_tour_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Shows the full trip history and lets the user create a new tour.
class TourHistoryScreen extends StatefulWidget {
  const TourHistoryScreen({super.key});

  @override
  State<TourHistoryScreen> createState() => _TourHistoryScreenState();
}

class _TourHistoryScreenState extends State<TourHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlobalContactsProvider>().seedDemoData();
      context.read<TourProvider>().seedDemoData();
    });
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  static void goToManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouteName.tourManage);
  }

  // ── New tour flow ──────────────────────────────────────────────────────────

  Future<void> _startNewTour(TourProvider provider) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TourNewTourSheet(provider: provider),
    );

    if (mounted && provider.hasActiveSession) {
      goToManagement(context);
    }
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────

  Future<void> _confirmDelete(TourProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Text('Remove this record?',
            style: TextStyle(
                fontFamily: MyString.poppinsBold, fontSize: 16.sp)),
        content: Text(
          'This tour history entry will be permanently deleted.',
          style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteSession(id);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<TourProvider>(
        builder: (ctx, provider, _) {
          return Column(
            children: [
              TourHistoryAppBar(onBack: () => Navigator.pop(context)),
              SizedBox(height: 8.h),

              // ── Active session resume card ─────────────────
              if (provider.hasActiveSession) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TourActiveSessionCard(
                    session: provider.activeSession!,
                    onResume: () => goToManagement(ctx),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // ── History list ───────────────────────────────
              Expanded(
                child: provider.history.isEmpty &&
                        !provider.hasActiveSession
                    ? TourEmptyHistoryState(
                        onNew: () => _startNewTour(provider))
                    : ListView.builder(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        itemCount: provider.history.length,
                        itemBuilder: (_, i) {
                          final session = provider.history[i];
                          return TourHistoryCard(
                            session: session,
                            onDelete: () =>
                                _confirmDelete(provider, session.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TourProvider>(
        builder: (ctx, provider, _) => FloatingActionButton.extended(
          onPressed: provider.hasActiveSession
              ? null
              : () => _startNewTour(provider),
          backgroundColor: provider.hasActiveSession
              ? Colors.grey.shade400
              : MyColor.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text('New Tour',
              style: TextStyle(
                  fontFamily: MyString.poppinsBold, fontSize: 13.sp)),
        ),
      ),
    );
  }
}
