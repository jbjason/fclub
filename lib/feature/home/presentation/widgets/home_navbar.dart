import 'dart:io';
import 'package:fclub/core/constants/my_icon.dart';
import 'package:flutter/material.dart';

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({
    super.key,
    required this.currentPage,
    required this.onPageChange,
  });
  final int currentPage;
  final Function onPageChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isAndroid
          ? kBottomNavigationBarHeight + 16
          : kBottomNavigationBarHeight + 25,
      padding: EdgeInsets.only(
        left: 7,
        right: 7,
        bottom: Platform.isAndroid ? 0 : 25,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getNavBarItem(0, MyIcon.home, MyIcon.homeFill),
          getNavBarItem(1, MyIcon.user, MyIcon.userFill),
        ],
      ),
    );
  }

  Widget getNavBarItem(int index, String img, String imgFill) {
    final isSelect = currentPage == index;
    return GestureDetector(
      onTap: () => onPageChange(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: kToolbarHeight,
        child: Image.asset(isSelect ? imgFill : img, width: 21),
      ),
    );
  }
}
