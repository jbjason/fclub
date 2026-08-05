import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupMemberAvatar extends StatelessWidget {
  const GroupMemberAvatar({super.key, required this.user, this.size = 42});

  final GroupUser user;
  final double size;

  static const _gradients = <List<Color>>[
    [MyColor.primary, Color(0xFF7C3AED)],
    [MyColor.secondary, Color(0xFF0284C7)],
    [MyColor.tertiary, Color(0xFFDB2777)],
    [MyColor.success, Color(0xFF059669)],
    [MyColor.warning, Color(0xFFEA580C)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[user.id.hashCode.abs() % _gradients.length];
    final initials = _initials(user.username);

    return Container(
      width: size.r,
      height: size.r,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          width: 2,
        ),
      ),
      child: user.profilePic.isNotEmpty
          ? Image.network(
              user.profilePic,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _Initials(initials: initials),
            )
          : _Initials(initials: initials),
    );
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: MyString.poppinsBold,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
