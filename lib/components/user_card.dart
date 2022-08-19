import 'package:flutter/material.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCard extends StatelessWidget {
  const UserCard(this.user, {Key? key}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    AppUser appUser = Provider.of<AppProvider>(context).user;

    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
        bottom: 5,
      ),
      child: Card(
        elevation: 3,
        color: CustomColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(user.photoUrl, 75, 35),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        color: CustomColors.grey4, fontSize: CustomFontSize.primary, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '@${user.userName}',
                    style: const TextStyle(
                        color: CustomColors.grey4, fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w400),
                  ),
                  Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: Provider.of<AppProvider>(context, listen: false).numberFollowing(appUser.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final users = snapshot.data?.docs;
                            List<String> ids = [];

                            for (var item in users!) {
                              ids.add(item.id.toString());
                            }
                            bool isFollowing = ids.contains(user.id);

                            if (isFollowing) {
                              return IconButton(
                                padding: const EdgeInsets.all(5),
                                splashRadius: 20,
                                splashColor: CustomColors.secondary,
                                color: CustomColors.secondary,
                                onPressed: () async {
                                  await Provider.of<AppProvider>(context, listen: false).unfollow(user.id);
                                },
                                icon: const Icon(
                                  Icons.group_remove,
                                ),
                              );
                            } else {
                              return IconButton(
                                padding: const EdgeInsets.all(5),
                                splashRadius: 20,
                                splashColor: CustomColors.secondary,
                                color: CustomColors.secondary,
                                onPressed: () async {
                                  await Provider.of<AppProvider>(context, listen: false).follow(user.id);
                                },
                                icon: const Icon(
                                  Icons.group_add_outlined,
                                ),
                              );
                            }
                          } else {
                            return IconButton(
                              padding: const EdgeInsets.all(5),
                              splashRadius: 20,
                              splashColor: CustomColors.secondary,
                              color: CustomColors.secondary,
                              onPressed: () {},
                              icon: const Icon(
                                Icons.home_outlined,
                              ),
                            );
                          }
                        },
                      ),
                      appUser.homeId != ''
                          ? FutureBuilder<MyHome?>(
                              future: Provider.of<AppProvider>(context, listen: false).fetchHome(appUser.homeId),
                              builder: (builder, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    MyHome myHome = snapshot.data!;

                                    if (myHome.creatorId == appUser.id) {
                                      return StreamBuilder<QuerySnapshot>(
                                        stream: Provider.of<AppProvider>(context, listen: false)
                                            .specificHomeInvite(user.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final invites = snapshot.data?.docs;
                                            List<String> ids = [];

                                            for (var item in invites!) {
                                              ids.add(item.id.toString());
                                            }
                                            bool inviteExists = ids.contains('${appUser.id}_${user.id}');

                                            if (inviteExists) {
                                              return IconButton(
                                                padding: const EdgeInsets.all(5),
                                                splashRadius: 20,
                                                splashColor: CustomColors.secondary,
                                                color: CustomColors.secondary,
                                                onPressed: () async {
                                                  NotificationService.notify('Uninviting to Home...');
                                                  await Provider.of<AppProvider>(context, listen: false)
                                                      .removeInviteToHome('${appUser.id}_${user.id}');
                                                },
                                                icon: const Icon(
                                                  Icons.home,
                                                ),
                                              );
                                            } else {
                                              return StreamBuilder<QuerySnapshot>(
                                                stream: Provider.of<AppProvider>(context, listen: false)
                                                    .specificHome(user.id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final homes = snapshot.data?.docs;
                                                    List<String> ids = [];

                                                    for (var item in homes!) {
                                                      ids.add(item.id.toString());
                                                    }
                                                    bool inHome = ids.contains(appUser.homeId);

                                                    if (inHome) {
                                                      return IconButton(
                                                        padding: const EdgeInsets.all(5),
                                                        splashRadius: 20,
                                                        splashColor: CustomColors.secondary,
                                                        color: CustomColors.secondary,
                                                        onPressed: () async {
                                                          await Provider.of<AppProvider>(context, listen: false)
                                                              .removeFromHome(user.id);
                                                        },
                                                        icon: const Icon(
                                                          Icons.home,
                                                        ),
                                                      );
                                                    } else {
                                                      return IconButton(
                                                        padding: const EdgeInsets.all(5),
                                                        splashRadius: 20,
                                                        splashColor: CustomColors.secondary,
                                                        color: CustomColors.secondary,
                                                        onPressed: () async {
                                                          await Provider.of<AppProvider>(context, listen: false)
                                                              .inviteToHome(user.id);
                                                        },
                                                        icon: const Icon(
                                                          Icons.home_outlined,
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    return IconButton(
                                                      padding: const EdgeInsets.all(5),
                                                      splashRadius: 20,
                                                      splashColor: CustomColors.secondary,
                                                      color: CustomColors.secondary,
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.home_outlined,
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }
                                          } else {
                                            return IconButton(
                                              padding: const EdgeInsets.all(5),
                                              splashRadius: 20,
                                              splashColor: CustomColors.secondary,
                                              color: CustomColors.secondary,
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.home_outlined,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  } else {
                                    return const SizedBox();
                                  }
                                } else {
                                  return const SizedBox();
                                }
                              },
                            )
                          : const SizedBox(),
                      IconButton(
                        padding: const EdgeInsets.all(5),
                        splashRadius: 20,
                        splashColor: CustomColors.secondary,
                        color: CustomColors.secondary,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.report_gmailerrorred_rounded,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
