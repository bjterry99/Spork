import 'package:flutter/material.dart';
import 'package:spork/components/search_bar.dart';
import 'package:spork/theme.dart';

class DelegateDiscover extends SliverPersistentHeaderDelegate {
  final Function search;
  final TextEditingController controller;
  final bool isOnRecipe;
  final Function changeSearch;

  DelegateDiscover(this.search, this.controller, this.isOnRecipe, this.changeSearch);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          children: [
            SearchBar(search: search, text: "I'm looking for...", controller: controller,),
            if (controller.text != '')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  changeSearch();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          'recipes',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: CustomFontSize.secondary,
                            color: CustomColors.secondary,
                          ),
                        ),
                        if (isOnRecipe)
                        Positioned(
                          top: 19,
                          left: 4.5,
                          child: Container(
                            height: 2.5,
                            width: 40,
                            decoration: BoxDecoration(
                              color: CustomColors.secondary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          'people',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: CustomFontSize.secondary,
                            color: CustomColors.secondary,
                          ),
                        ),
                        if (!isOnRecipe)
                          Positioned(
                            top: 19,
                            left: 3,
                            child: Container(
                              height: 2.5,
                              width: 40,
                              decoration: BoxDecoration(
                                color: CustomColors.secondary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
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