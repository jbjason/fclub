import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_global_contact.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_session.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/screens/kurbani_management_screen.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_member_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ── Kurbani colour constants ───────────────────────────────────────────────
const _kDeepEmerald = Color(0xFF064E3B);
const _kGold = Color(0xFFF59E0B);
const _kEmerald = Color(0xFF10B981);
const _kRose = Color(0xFFEF4444);

/// Shows the annual Kurbani log and lets the user start a new session.
class KurbaniHistoryScreen extends StatefulWidget {
  const KurbaniHistoryScreen({super.key});

  @override
  State<KurbaniHistoryScreen> createState() => _KurbaniHistoryScreenState();
}

class _KurbaniHistoryScreenState extends State<KurbaniHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KurbaniProvider>().seedDemoData();
    });
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  static void goToManagement(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const KurbaniManagementScreen(),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  // ── New session flow ───────────────────────────────────────────────────────

  Future<void> _startNewSession(KurbaniProvider provider) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewKurbaniSheet(provider: provider),
    );

    // If a session was just created, navigate to management
    if (mounted && provider.hasActiveSession) {
      goToManagement(context);
    }
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────

  Future<void> _confirmDelete(
      KurbaniProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Remove this record?',
          style: TextStyle(
              fontFamily: MyString.poppinsBold, fontSize: 16.sp),
        ),
        content: Text(
          'This Kurbani history entry will be permanently deleted.',
          style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 13.sp,
              color: Colors.black54,
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
              backgroundColor: _kRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteSession(id);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Consumer<KurbaniProvider>(
        builder: (ctx, provider, _) {
          return Column(
            children: [
              _KurbaniHistoryAppBar(onBack: () => Navigator.pop(context)),
              SizedBox(height: 8.h),

              // ── Active session resume card ─────────────────
              if (provider.hasActiveSession) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _ActiveSessionCard(
                    session: provider.activeSession!,
                    onResume: () => goToManagement(ctx),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // ── History list ───────────────────────────────
              Expanded(
                child: provider.history.isEmpty && !provider.hasActiveSession
                    ? _EmptyHistoryState(
                        onNew: () => _startNewSession(provider))
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        itemCount: provider.history.length,
                        itemBuilder: (_, i) {
                          final session = provider.history[i];
                          return _HistoryCard(
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
      floatingActionButton: Consumer<KurbaniProvider>(
        builder: (ctx, provider, _) => FloatingActionButton.extended(
          onPressed: provider.hasActiveSession
              ? null
              : () => _startNewSession(provider),
          backgroundColor:
              provider.hasActiveSession ? Colors.grey.shade400 : _kDeepEmerald,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'New Kurbani',
            style: TextStyle(
                fontFamily: MyString.poppinsBold, fontSize: 13.sp),
          ),
        ),
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────

class _KurbaniHistoryAppBar extends StatelessWidget {
  const _KurbaniHistoryAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF1A3A6B), Color(0xFF1E1B4B)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 16.h),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 20.r),
                onPressed: onBack,
              ),
              SizedBox(width: 4.w),
              // Crescent icon
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _kGold.withValues(alpha: 0.3),
                    _kGold.withValues(alpha: 0.05),
                  ]),
                ),
                child: Icon(Icons.nightlight_round,
                    size: 20.r, color: _kGold),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kurbani',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Annual log',
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active session banner ──────────────────────────────────────────────────

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard(
      {required this.session, required this.onResume});

  final KurbaniSession session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF1A3A6B)],
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _kDeepEmerald.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.nightlight_round, color: _kGold, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'IN PROGRESS',
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 9.sp,
                            color: _kGold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    session.groupName,
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${session.members.length} members · ${CurrencyFormatter.format(session.totalSpent)} spent',
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _kGold,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Resume',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History card ───────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session, required this.onDelete});

  final KurbaniSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final spent = session.totalSpent;
    final budget = session.totalBudget;
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;
    final progressColor = isOver ? _kRose : _kEmerald;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _KurbaniHistoryDetailSheet.show(context, session),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ───────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: _kDeepEmerald.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.nightlight_round,
                          color: _kDeepEmerald, size: 18.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.groupName,
                            style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 14.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            DateFormat('d MMM y').format(session.createdAt),
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 11.sp,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.black26, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Spending progress bar ─────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent',
                                style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 11.sp,
                                  color: Colors.black45,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget)}',
                                style: TextStyle(
                                  fontFamily: MyString.poppinsBold,
                                  fontSize: 11.sp,
                                  color: isOver ? _kRose : _kDeepEmerald,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6.h,
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.06),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  progressColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Chips row ─────────────────────────────────
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label:
                          '${session.members.length} members',
                      color: const Color(0xFF6D28D9),
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.receipt_long_rounded,
                      label:
                          '${session.expenses.length} expenses',
                      color: const Color(0xFF0891B2),
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.set_meal_rounded,
                      label:
                          '${session.animalParts.length} parts',
                      color: _kEmerald,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Info chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 10.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nightlight_round,
              size: 64.r, color: _kDeepEmerald.withValues(alpha: 0.2)),
          SizedBox(height: 16.h),
          Text(
            'No Kurbani records yet',
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 16.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the button below to start your\nfirst Kurbani management.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 13.sp,
              color: Colors.black45,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Start New Kurbani',
              style: TextStyle(
                  fontFamily: MyString.poppinsBold, fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kDeepEmerald,
              foregroundColor: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History detail bottom sheet ────────────────────────────────────────────

class _KurbaniHistoryDetailSheet {
  static void show(
      BuildContext context, KurbaniSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryDetailSheetContent(session: session),
    );
  }
}

class _HistoryDetailSheetContent extends StatelessWidget {
  const _HistoryDetailSheetContent({required this.session});
  final KurbaniSession session;

  @override
  Widget build(BuildContext context) {
    final spent = session.totalSpent;
    final budget = session.totalBudget;
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          children: [
            // drag handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: _kDeepEmerald.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.nightlight_round,
                      color: _kDeepEmerald, size: 22.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.groupName,
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 16.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM y')
                            .format(session.createdAt),
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 11.sp,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Budget summary
            _DetailSection(
              title: 'Budget Summary',
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Budget / member',
                    value: CurrencyFormatter.format(session.budgetPerMember),
                  ),
                  _SummaryRow(
                    label: 'Total budget',
                    value: CurrencyFormatter.format(budget),
                  ),
                  _SummaryRow(
                    label: 'Total spent',
                    value: CurrencyFormatter.format(spent),
                    valueColor: isOver ? _kRose : _kDeepEmerald,
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.h,
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOver ? _kRose : _kEmerald),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Members
            _DetailSection(
              title:
                  'Members (${session.members.length})',
              child: Column(
                children: session.members.map((m) {
                  final initials =
                      m.name.trim().split(' ').length >= 2
                          ? '${m.name.split(' ')[0][0]}${m.name.split(' ')[1][0]}'
                              .toUpperCase()
                          : m.name.substring(0, 1).toUpperCase();
                  final gradients = kurbaniAvatarGradients[
                      m.avatarColorIndex %
                          kurbaniAvatarGradients.length];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 34.r,
                          height: 34.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradients,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 11.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            m.name,
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 13.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(m.contribution),
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 12.sp,
                            color: _kDeepEmerald,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),

            // Expenses
            _DetailSection(
              title:
                  'Expenses (${session.expenses.length})',
              child: Column(
                children: session.expenses.map((e) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.title,
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 13.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(e.amount),
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 12.sp,
                            color: _kRose,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontSize: 13.sp,
            color: _kDeepEmerald,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12.sp,
                  color: Colors.black45)),
          Text(value,
              style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: valueColor ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// ── New Kurbani bottom sheet ───────────────────────────────────────────────

class _NewKurbaniSheet extends StatefulWidget {
  const _NewKurbaniSheet({required this.provider});
  final KurbaniProvider provider;

  @override
  State<_NewKurbaniSheet> createState() => _NewKurbaniSheetState();
}

class _NewKurbaniSheetState extends State<_NewKurbaniSheet> {
  int _step = 0;

  // Step 1
  final _groupNameCtrl = TextEditingController(text: 'Kurbani 1447 H');
  final _budgetCtrl = TextEditingController(text: '3000');
  final _formKey = GlobalKey<FormState>();

  // Step 2
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _groupNameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 3000;
    await widget.provider.createSession(
      groupName: _groupNameCtrl.text.trim(),
      budgetPerMember: budget,
      selectedContactIds: _selectedIds.toList(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Header
            _SheetHeader(
              step: _step,
              onBack: _step == 1
                  ? () => setState(() => _step = 0)
                  : null,
            ),

            if (_step == 0)
              _StepOneContent(
                formKey: _formKey,
                groupNameCtrl: _groupNameCtrl,
                budgetCtrl: _budgetCtrl,
                onNext: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
              )
            else
              _StepTwoContent(
                contacts: widget.provider.contacts,
                meId: widget.provider.meContact?.id,
                selectedIds: _selectedIds,
                onToggle: (id) =>
                    setState(() => _selectedIds.contains(id)
                        ? _selectedIds.remove(id)
                        : _selectedIds.add(id)),
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet header ───────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.step, this.onBack});
  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: _kDeepEmerald, size: 18.r),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step == 0 ? 'New Kurbani' : 'Select Participants',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 17.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  step == 0
                      ? 'Step 1 of 2 · Group details'
                      : 'Step 2 of 2 · Choose members',
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          // step indicators
          Row(
            children: List.generate(2, (i) {
              return Container(
                margin: EdgeInsets.only(left: 4.w),
                width: 22.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: i == step
                      ? _kDeepEmerald
                      : _kDeepEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Step 1 — Group details ─────────────────────────────────────────────────

class _StepOneContent extends StatelessWidget {
  const _StepOneContent({
    required this.formKey,
    required this.groupNameCtrl,
    required this.budgetCtrl,
    required this.onNext,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController groupNameCtrl;
  final TextEditingController budgetCtrl;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Group / Year label'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: groupNameCtrl,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: _inputDeco(
                  hint: 'e.g. Kurbani 1447 H',
                  icon: Icons.nightlight_round),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _FieldLabel('Budget per member (৳)'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: budgetCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: _inputDeco(
                  hint: '3000', icon: Icons.savings_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kDeepEmerald,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  'Next: Select Members',
                  style: TextStyle(
                      fontFamily: MyString.poppinsBold, fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 — Member selection ──────────────────────────────────────────────

class _StepTwoContent extends StatelessWidget {
  const _StepTwoContent({
    required this.contacts,
    required this.meId,
    required this.selectedIds,
    required this.onToggle,
    required this.onSubmit,
  });
  final List<KurbaniGlobalContact> contacts;
  final String? meId;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        selectedIds.length + 1; // +1 for "me" (always included)

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contact list
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 340.h),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: contacts.length,
            itemBuilder: (_, i) {
              final c = contacts[i];
              final isMe = c.id == meId;
              final isSelected = isMe || selectedIds.contains(c.id);
              final gradients = kurbaniAvatarGradients[
                  c.avatarColorIndex % kurbaniAvatarGradients.length];
              final initials = c.name.trim().split(' ').length >= 2
                  ? '${c.name.split(' ')[0][0]}${c.name.split(' ')[1][0]}'
                      .toUpperCase()
                  : c.name.substring(0, 1).toUpperCase();

              return GestureDetector(
                onTap: isMe ? null : () => onToggle(c.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kDeepEmerald.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? _kDeepEmerald.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradients,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 13.sp,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            if (isMe)
                              Text(
                                'Creator · always included',
                                style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 10.sp,
                                  color: _kGold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isMe)
                        Icon(Icons.star_rounded,
                            color: _kGold, size: 18.r)
                      else if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: _kDeepEmerald, size: 20.r)
                      else
                        Icon(Icons.radio_button_unchecked_rounded,
                            color: Colors.black26, size: 20.r),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Submit
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kDeepEmerald,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: Text(
                'Create Kurbani ($selectedCount members)',
                style: TextStyle(
                    fontFamily: MyString.poppinsBold, fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDeco({required String hint, required IconData icon}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: _kDeepEmerald),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kDeepEmerald, width: 1.5),
    ),
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: MyString.poppinsBold,
        fontSize: 12.sp,
        color: const Color(0xFF334155),
      ),
    );
  }
}
