import 'package:flutter/material.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/following_followers.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const spacerSize = 10.0;

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({required this.user, Key? key}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    AppUser appUser = Provider.of<AppProvider>(context).user;

    return Material(
      color: CustomColors.white,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      elevation: 0,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Hero(tag: user.id, child: ProfileImage(user.photoUrl, 50, 45)),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 95,
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => FollowingFollowers(
                                title: 'Followers',
                                user: user,
                              ),
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
                        const SizedBox(
                          width: spacerSize,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => FollowingFollowers(
                                title: 'Following',
                                user: user,
                              ),
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
                        const SizedBox(
                          width: spacerSize,
                        ),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: Provider.of<AppProvider>(context, listen: false).specificUser(user.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final streamUser = snapshot.data!;
                              final modelUser = AppUser.fromJson(streamUser.data()!);
                              return MyTextButton(
                                  text: modelUser.followers.contains(appUser.id) ? 'following' : 'follow',
                                  action: () async {
                                    if (modelUser.followers.contains(appUser.id)) {
                                      await Provider.of<AppProvider>(context, listen: false).unfollow(user.id);
                                    } else {
                                      await Provider.of<AppProvider>(context, listen: false).follow(user.id);
                                    }
                                  });
                            }
                            return MyTextButton(text: 'follow', action: () {});
                          },
                        ),
                        const Spacer()
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
