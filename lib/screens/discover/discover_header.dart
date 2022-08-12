import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spork/components/buttons/custom_button.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/my_home_screen/my_home_screen_load.dart';
import 'package:spork/screens/settings.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({required this.isOnFollow, required this.change, Key? key}) : super(key: key);
  final Function change;
  final bool isOnFollow;

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;
    double numberSpacing = MediaQuery.of(context).size.width/18;

    return Material(
      color: CustomColors.white,
      borderRadius:
      const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      elevation: 1,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: Platform.isAndroid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: Platform.isAndroid ? 10 : 0,),
                child: Text(
                  isOnFollow ? 'Following' : 'Explore',
                  style: const TextStyle(
                      color: CustomColors.grey4,
                      fontSize: CustomFontSize.big,
                      fontWeight: FontWeight.w500),
                ),
              ),
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
                        content: Icon(Icons.restaurant_menu_rounded, color: isOnFollow ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: !isOnFollow),
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.menu_book_rounded, color: !isOnFollow ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: isOnFollow),
                  ],
                ),
              )
            ],
          ),
        ),
      ),);
  }
}
