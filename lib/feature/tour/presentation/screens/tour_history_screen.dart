import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
      builder: (_) => _NewTourSheet(provider: provider),
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
              backgroundColor: MyColor.error,
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
      backgroundColor: MyColor.surface,
      body: Consumer<TourProvider>(
        builder: (ctx, provider, _) {
          return Column(
            children: [
              _TourHistoryAppBar(onBack: () => Navigator.pop(context)),
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
                child: provider.history.isEmpty &&
                        !provider.hasActiveSession
                    ? _EmptyHistoryState(
                        onNew: () => _startNewTour(provider))
                    : ListView.builder(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
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

// ── App bar ────────────────────────────────────────────────────────────────

class _TourHistoryAppBar extends StatelessWidget {
  const _TourHistoryAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MyColor.primary, MyColor.secondary, MyColor.tertiary],
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
              Container(
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.card_travel_rounded,
                    size: 20.r, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tour',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Trip history',
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: Colors.white60,
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

// ── Active session resume banner ───────────────────────────────────────────

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard(
      {required this.session, required this.onResume});
  final TourSession session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MyColor.primary, MyColor.secondary],
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: MyColor.primary.withValues(alpha: 0.35),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_travel_rounded,
                  color: Colors.white, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 9.sp,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    session.tourName,
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
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Resume',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: MyColor.primary,
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
  final TourSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final spent = session.totalSpent;
    final budget = session.decidedBudget;
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;
    final progressColor = isOver ? MyColor.error : MyColor.success;

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
          onTap: () =>
              _TourHistoryDetailSheet.show(context, session),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: MyColor.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.card_travel_rounded,
                          color: MyColor.primary, size: 18.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.tourName,
                            style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 14.sp,
                              color: MyColor.onSurface,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM y')
                                .format(session.createdAt),
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 11.sp,
                              color: MyColor.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline_rounded,
                          color: MyColor.gray300, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Spending bar ────────────────────────────────
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spent',
                        style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 11.sp,
                            color: MyColor.gray400)),
                    Text(
                      '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget)}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 11.sp,
                        color: isOver
                            ? MyColor.error
                            : MyColor.primary,
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
                        MyColor.gray100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor),
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Chips ───────────────────────────────────────
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label:
                          '${session.members.length} members',
                      color: MyColor.primary,
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.receipt_long_rounded,
                      label:
                          '${session.expenses.length} expenses',
                      color: MyColor.secondary,
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.payments_rounded,
                      label:
                          '${session.extraPayments.length} payments',
                      color: MyColor.tertiary,
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
          Text(label,
              style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10.sp,
                  color: color)),
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
          Icon(Icons.card_travel_rounded,
              size: 64.r,
              color: MyColor.primary.withValues(alpha: 0.2)),
          SizedBox(height: 16.h),
          Text('No trips yet',
              style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 16.sp,
                  color: MyColor.onSurface)),
          SizedBox(height: 6.h),
          Text(
            'Tap the button below to start your\nfirst trip management.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 13.sp,
                color: MyColor.gray400,
                height: 1.5),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: Text('Start New Tour',
                style: TextStyle(
                    fontFamily: MyString.poppinsBold, fontSize: 13.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primary,
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

// ── History detail sheet ───────────────────────────────────────────────────

class _TourHistoryDetailSheet {
  static void show(BuildContext context, TourSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryDetailContent(session: session),
    );
  }
}

class _HistoryDetailContent extends StatelessWidget {
  const _HistoryDetailContent({required this.session});
  final TourSession session;

  @override
  Widget build(BuildContext context) {
    final spent = session.totalSpent;
    final budget = session.decidedBudget;
    final collected = session.totalCollected;
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
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: MyColor.gray200,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),

            // Title row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: MyColor.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.card_travel_rounded,
                      color: MyColor.primary, size: 22.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.tourName,
                        style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 16.sp,
                            color: MyColor.onSurface),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM y')
                            .format(session.createdAt),
                        style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 11.sp,
                            color: MyColor.gray400),
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
                      label: 'Decided budget',
                      value: CurrencyFormatter.format(budget)),
                  _SummaryRow(
                      label: 'Collected',
                      value: CurrencyFormatter.format(collected),
                      valueColor: MyColor.success),
                  _SummaryRow(
                      label: 'Total spent',
                      value: CurrencyFormatter.format(spent),
                      valueColor:
                          isOver ? MyColor.error : MyColor.primary),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.h,
                      backgroundColor: MyColor.gray100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOver ? MyColor.error : MyColor.success),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Members
            _DetailSection(
              title: 'Members (${session.members.length})',
              child: Column(
                children: session.members.map((m) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        TourMemberAvatar(
                          name: m.name,
                          colorIndex: m.avatarColorIndex,
                          radius: 17.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(m.name,
                              style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 13.sp,
                                  color: MyColor.onSurface)),
                        ),
                        Text(
                          CurrencyFormatter.format(m.paidToManager),
                          style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: MyColor.primary),
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
              title: 'Expenses (${session.expenses.length})',
              child: Column(
                children: session.expenses.map((e) {
                  final cat = ExpenseCategory
                      .values[e.categoryIndex % ExpenseCategory.values.length];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 16.r, color: cat.color),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(e.title,
                              style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 13.sp,
                                  color: MyColor.onSurface)),
                        ),
                        Text(
                          CurrencyFormatter.format(e.amount),
                          style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: MyColor.error),
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
        Text(title,
            style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 13.sp,
                color: MyColor.primary,
                letterSpacing: 0.3)),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
              color: MyColor.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14.r)),
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
                  color: MyColor.gray400)),
          Text(value,
              style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: valueColor ?? MyColor.onSurface)),
        ],
      ),
    );
  }
}

// ── New Tour bottom sheet ──────────────────────────────────────────────────

class _NewTourSheet extends StatefulWidget {
  const _NewTourSheet({required this.provider});
  final TourProvider provider;

  @override
  State<_NewTourSheet> createState() => _NewTourSheetState();
}

class _NewTourSheetState extends State<_NewTourSheet> {
  int _step = 0;

  // Step 1
  final _tourNameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '20000');
  final _formKey = GlobalKey<FormState>();

  // Step 2
  final List<String> _memberNames = [];
  final _memberCtrl = TextEditingController();

  @override
  void dispose() {
    _tourNameCtrl.dispose();
    _budgetCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _memberNames.add(name);
      _memberCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (_memberNames.isEmpty) return;
    final budget =
        double.tryParse(_budgetCtrl.text.trim()) ?? 20000;
    await widget.provider.createSession(
      tourName: _tourNameCtrl.text.trim(),
      decidedBudget: budget,
      memberNames: _memberNames,
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
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: MyColor.gray200,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            _SheetHeader(
              step: _step,
              onBack:
                  _step == 1 ? () => setState(() => _step = 0) : null,
            ),
            if (_step == 0)
              _StepOneContent(
                formKey: _formKey,
                tourNameCtrl: _tourNameCtrl,
                budgetCtrl: _budgetCtrl,
                onNext: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
              )
            else
              _StepTwoContent(
                memberNames: _memberNames,
                memberCtrl: _memberCtrl,
                onAdd: _addMember,
                onRemove: (i) =>
                    setState(() => _memberNames.removeAt(i)),
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
                  color: MyColor.primary, size: 18.r),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step == 0 ? 'New Tour' : 'Add Members',
                  style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 17.sp,
                      color: MyColor.onSurface),
                ),
                Text(
                  step == 0
                      ? 'Step 1 of 2 · Trip details'
                      : 'Step 2 of 2 · Who\'s coming?',
                  style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: MyColor.gray400),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(2, (i) {
              return Container(
                margin: EdgeInsets.only(left: 4.w),
                width: 22.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: i == step
                      ? MyColor.primary
                      : MyColor.primary.withValues(alpha: 0.15),
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

// ── Step 1 — Trip details ──────────────────────────────────────────────────

class _StepOneContent extends StatelessWidget {
  const _StepOneContent({
    required this.formKey,
    required this.tourNameCtrl,
    required this.budgetCtrl,
    required this.onNext,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController tourNameCtrl;
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
            _FieldLabel('Trip name'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: tourNameCtrl,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: _inputDeco(
                  hint: "e.g. Cox's Bazar Trip",
                  icon: Icons.card_travel_rounded),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _FieldLabel('Decided budget (৳)'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: budgetCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: _inputDeco(
                  hint: '20000', icon: Icons.savings_rounded),
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
                  backgroundColor: MyColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Next: Add Members',
                    style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 — Members ───────────────────────────────────────────────────────

class _StepTwoContent extends StatelessWidget {
  const _StepTwoContent({
    required this.memberNames,
    required this.memberCtrl,
    required this.onAdd,
    required this.onRemove,
    required this.onSubmit,
  });
  final List<String> memberNames;
  final TextEditingController memberCtrl;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: memberCtrl,
                  style: TextStyle(
                      fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
                  decoration: _inputDeco(
                      hint: 'Member name',
                      icon: Icons.person_add_rounded),
                  onFieldSubmitted: (_) => onAdd(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: MyColor.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.add_rounded,
                      color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Member chips
          if (memberNames.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: memberNames.asMap().entries.map((entry) {
                final i = entry.key;
                final name = entry.value;
                final color =
                    TourMemberAvatar.colorFor(i);
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: color)),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () => onRemove(i),
                        child: Icon(Icons.close_rounded,
                            size: 14.r,
                            color: color.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  memberNames.isNotEmpty ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: MyColor.gray200,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: Text(
                memberNames.isEmpty
                    ? 'Add at least one member'
                    : 'Create Tour (${memberNames.length} members)',
                style: TextStyle(
                    fontFamily: MyString.poppinsBold, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDeco(
    {required String hint, required IconData icon}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: MyColor.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColor.gray200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColor.gray200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColor.primary, width: 1.5),
    ),
    filled: true,
    fillColor: MyColor.surfaceContainerLow,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontSize: 12.sp,
            color: MyColor.onSurfaceVariant));
  }
}
