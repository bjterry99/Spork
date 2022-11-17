import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/following_followers.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({required this.user, Key? key}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Platform.isAndroid ? const Icon(Icons.arrow_back) : const Icon(Icons.arrow_back_ios),
                    ),
                    const SizedBox(width: 10,),
                    Hero(tag: user.id, child: ProfileImage(user.photoUrl, 90, 60)),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width/1.9,
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
                          width: MediaQuery.of(context).size.width/1.9,
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
                          width: MediaQuery.of(context).size.width - 90 - 25 - 15 - 40,
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
                              const Spacer(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),);
  }
}
