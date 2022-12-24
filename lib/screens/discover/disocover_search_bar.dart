import 'package:flutter/material.dart';
import 'package:spork/components/search_bar.dart';
import 'package:spork/theme.dart';

class DelegateDiscover extends SliverPersistentHeaderDelegate {
  final Function search;
  final TextEditingController controller;
  final bool isOnRecipe;
  final Function changeSearch;
  final Function clear;
  final bool viewButtons;

  DelegateDiscover(this.search, this.controller, this.isOnRecipe, this.changeSearch, this.clear, this.viewButtons);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          children: [
            SearchBar(search: search, text: "Search for recipes or people...", controller: controller, clear: clear,),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0, boldText: false),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    changeSearch();
                  },
                  child: viewButtons ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'recipes',
                        style: TextStyle(
                          fontWeight: !isOnRecipe ? FontWeight.w400 : FontWeight.w800,
                          fontSize: CustomFontSize.secondary,
                          color: CustomColors.secondary,
                        ),
                      ),
                      Text(
                        'people',
                        style: TextStyle(
                          fontWeight: isOnRecipe ? FontWeight.w400 : FontWeight.w800,
                          fontSize: CustomFontSize.secondary,
                          color: CustomColors.secondary,
                        ),
                      )
                    ],
                  ) : const SizedBox(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 107;

  @override
  double get minExtent => 107;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}