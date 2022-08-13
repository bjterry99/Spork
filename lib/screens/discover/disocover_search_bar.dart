import 'package:flutter/material.dart';
import 'package:spork/components/buttons/custom_button.dart';
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
      child: Container(
        decoration: const BoxDecoration(
          color: CustomColors.white,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black38, spreadRadius: 1.2, blurRadius: 1.3),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Column(
            children: [
              SearchBar(search: search, text: "I'm looking for...", controller: controller,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.restaurant_menu_rounded, color: isOnRecipe ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          changeSearch();
                        },
                        isActive: !isOnRecipe),
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.person, color: !isOnRecipe ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          changeSearch();
                        },
                        isActive: isOnRecipe),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 123;

  @override
  double get minExtent => 123;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}