import 'package:flutter/material.dart';
import 'package:spork/components/search_bar.dart';

class UserDelegateProfile extends SliverPersistentHeaderDelegate {
  final Function search;
  final TextEditingController controller;

  UserDelegateProfile(this.search, this.controller);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: SearchBar(search: search, text: 'Search recipes...', controller: controller,),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}