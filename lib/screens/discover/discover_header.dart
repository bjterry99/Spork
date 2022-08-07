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
  const DiscoverHeader({required this.isOnRecipe, required this.change, Key? key}) : super(key: key);
  final Function change;
  final bool isOnRecipe;

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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      onTap: () {
                        if (Platform.isIOS) {
                          Navigator.of(context).push(SwipeablePageRoute(
                              builder: (BuildContext context) => SettingsPage(user: user,),
                              canOnlySwipeFromEdge: true
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SettingsPage(user: user,),
                          ));
                        }
                      },
                      child: ProfileImage(user.photoUrl, 90, 60)),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                            color: CustomColors.grey4,
                            fontSize: CustomFontSize.big,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '@${user.userName}',
                        style: const TextStyle(
                            color: CustomColors.grey4,
                            fontSize: CustomFontSize.secondary,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Followers',
                                style: TextStyle(
                                    color: CustomColors.grey4,
                                    fontSize: CustomFontSize.secondary,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                user.followers.length.toString(),
                                style: const TextStyle(
                                    color: CustomColors.grey4,
                                    fontSize: CustomFontSize.secondary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: numberSpacing,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Following',
                                style: TextStyle(
                                    color: CustomColors.grey4,
                                    fontSize: CustomFontSize.secondary,
                                    fontWeight: FontWeight.w400),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: Provider.of<AppProvider>(context, listen: false).numberFollowing(user.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final menuItems = snapshot.data?.docs;

                                    return Text(
                                      menuItems!.length.toString(),
                                      style: const TextStyle(
                                          color: CustomColors.grey4,
                                          fontSize: CustomFontSize.secondary,
                                          fontWeight: FontWeight.w600),
                                    );
                                  } else {
                                    return const Text(
                                      '0',
                                      style: TextStyle(
                                          color: CustomColors.grey4,
                                          fontSize: CustomFontSize.secondary,
                                          fontWeight: FontWeight.w600),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                          SizedBox(
                            width: numberSpacing,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (Platform.isIOS) {
                                Navigator.of(context).push(SwipeablePageRoute(
                                    builder: (BuildContext context) => const MyHomeScreenLoad(),
                                    canOnlySwipeFromEdge: true
                                ));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => const MyHomeScreenLoad(),
                                ));
                              }
                            },
                            child: Column(
                              children: const [
                                Text(
                                  'My',
                                  style: TextStyle(
                                      color: CustomColors.grey4,
                                      fontSize: CustomFontSize.secondary,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Home',
                                  style: TextStyle(
                                      color: CustomColors.grey4,
                                      fontSize: CustomFontSize.secondary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
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
                        content: Icon(Icons.restaurant_menu_rounded, color: isOnRecipe ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: !isOnRecipe),
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.menu_book_rounded, color: !isOnRecipe ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: isOnRecipe),
                  ],
                ),
              )
            ],
          ),
        ),
      ),);
  }
}
