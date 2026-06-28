import 'package:flutter/material.dart';

class TourTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  TourTabBarHeaderDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).cardColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant TourTabBarHeaderDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
