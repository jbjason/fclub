import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: MyColor.gray500,
              fontFamily: MyString.poppinsBold,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: MyColor.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: MyColor.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: MyColor.black.withValues(alpha: 0.03),
                offset: Offset(0, 4.h),
                blurRadius: 12.r,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Column(
              children: _buildChildren(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren() {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Padding(
            padding: EdgeInsets.only(left: 64.w),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: MyColor.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        );
      }
    }
    return items;
  }
}
