import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/core/constants/my_color.dart';

class MyDimens {
  static const cmDivider = Divider(color: MyColor.gray300, thickness: .5);

  Center getDemoPage(String title) => Center(child: Text(title));

  static List<BoxShadow> get getShadow => [
    BoxShadow(
      offset: Offset(5.w, 5.h),
      blurRadius: 5.r,
      color: MyColor.gray300,
    ),
  ];

  static BoxDecoration get getBoxDecoration => BoxDecoration(
    color: MyColor.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: MyColor.outlineVariant, width: 1.w),
    boxShadow: [
      BoxShadow(
        color: MyColor.gray200.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static Center get getLoadingIndication =>
      const Center(child: CircularProgressIndicator());

  static Center get getNoItemText => const Center(
    child: SizedBox(
      height: 800,
      width: 80,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No data found..',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );

  AppBar getNormalAppBar(
    String title,
    List<Widget> actions,
    BuildContext ctx, [
    bool backButton = false,
  ]) {
    return AppBar(
      leading: backButton
          ? IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      automaticallyImplyLeading: false,
      actions: actions,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  SliverAppBar getSliverAppbar(
    String title,
    List<Widget> actions,
    BuildContext ctx, [
    bool backButton = false,
  ]) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: AppTheme.isTablet(ctx) ? true : false,
      leading: backButton
          ? IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      actions: actions,
      expandedHeight: AppTheme.getResponsiveSize(ctx, 200.h, 140.h, 250.h),
      floating: AppTheme.isMobile(ctx) ? true : false,
      snap: AppTheme.isMobile(ctx) ? true : false,
      elevation: AppTheme.isTablet(ctx) ? 4.0 : 0.0,
      backgroundColor: MyColor.primary,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: MyColor.primary),
        centerTitle: AppTheme.isTablet(ctx) ? true : false,
      ),
    );
  }

  Padding getTitleAndViewAll(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 12.w, right: 12.w, bottom: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w900,
              color: MyColor.gray900,
            ),
          ),
          Text(
            "View All",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColor.success,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
