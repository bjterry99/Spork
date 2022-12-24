import 'package:flutter/material.dart';
import 'package:spork/components/my_switcher.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/following_followers.dart';
import 'package:spork/screens/my_home_screen/my_home_screen_load.dart';
import 'package:spork/screens/settings.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.isOnRecipe, required this.change, Key? key}) : super(key: key);
  final Function change;
  final bool isOnRecipe;

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0, boldText: false),
      child: Material(
          color: CustomColors.white,
          borderRadius:
          const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          elevation: 3,
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
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SettingsPage(user: user,),
                          ));
                        },
                          child: ProfileImage(user.photoUrl, 90, 60)),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.6,
                            child: Text(
                              user.name,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: const TextStyle(
                                  color: CustomColors.grey4,
                                  fontSize: CustomFontSize.big,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.6,
                            child: Text(
                              '@${user.userName}',
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: const TextStyle(
                                  color: CustomColors.grey4,
                                  fontSize: CustomFontSize.secondary,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 90 - 25 - 15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Spacer(),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => FollowingFollowers(title: 'Followers', user: user,),
                                    ));
                                  },
                                  child: Column(
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
                                ),
                                const SizedBox(width: 25,),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => FollowingFollowers(title: 'Following', user: user,),
                                    ));
                                  },
                                  child: Column(
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
                                ),
                                const SizedBox(width: 25,),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => const MyHomeScreenLoad(),
                                    ));
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
                                const Spacer(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: MySwitcher(change: change, isOnFollow: isOnRecipe, iconRight: Icons.restaurant_menu_rounded, iconLeft: Icons.menu_book_rounded)
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: IconButton(onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SettingsPage(user: user,),
                          ));
                        }, icon: const Icon(Icons.settings, color: CustomColors.grey4,)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),),
    );
  }
}
