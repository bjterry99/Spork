import 'package:flutter/material.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/user_profile_page/user_profile.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/services/notification_service.dart';
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

    return GestureDetector(
      onTap: () {
        if (appUser.id != user.id) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => UserProfileScreen(user: user,),
          ));
        }
      },
      child: Padding(
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
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: appUser.id != user.id ? 0 : 10),
            child: Row(
              crossAxisAlignment: appUser.id != user.id ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Hero(tag: user.id, child: ProfileImage(user.photoUrl, 75, 35)),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width/1.8,
                      child: Text(
                        user.name,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                            color: CustomColors.grey4, fontSize: CustomFontSize.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/1.8,
                      child: Text(
                        '@${user.userName}',
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                            color: CustomColors.grey4, fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w400),
                      ),
                    ),
                    if (appUser.id != user.id )
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
                                                    bool? answer = await DialogService.dialogBox(
                                                      context: context,
                                                      title: 'Unsend Invite?',
                                                      actions: [
                                                        InfoBoxButton(
                                                          action: () {
                                                            Navigator.of(context).pop(false);
                                                          },
                                                          text: 'Cancel',
                                                          isPrimary: true,
                                                        ),
                                                        InfoBoxButton(
                                                          action: () {
                                                            Navigator.of(context).pop(true);
                                                          },
                                                          text: 'Confirm',
                                                          isPrimary: true,
                                                        ),
                                                      ],
                                                    );
                                                    bool checkForNullAnswer = answer ?? false;
                                                    if (checkForNullAnswer) {
                                                      NotificationService.notify('Uninviting to Home...');
                                                      await Provider.of<AppProvider>(context, listen: false)
                                                          .removeInviteToHome('${appUser.id}_${user.id}');
                                                    }
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
                                                            bool? answer = await DialogService.dialogBox(
                                                              context: context,
                                                              title: 'Remove ${user.name} from Home?',
                                                              body: const Text(
                                                                'You may lose access to their recipes.',
                                                                style: InfoBoxTextStyle.body,
                                                              ),
                                                              actions: [
                                                                InfoBoxButton(
                                                                  action: () {
                                                                    Navigator.of(context).pop(false);
                                                                  },
                                                                  text: 'Cancel',
                                                                  isPrimary: true,
                                                                ),
                                                                InfoBoxButton(
                                                                  action: () {
                                                                    Navigator.of(context).pop(true);
                                                                  },
                                                                  text: 'Confirm',
                                                                  isPrimary: true,
                                                                ),
                                                              ],
                                                            );
                                                            bool checkForNullAnswer = answer ?? false;
                                                            if (checkForNullAnswer) {
                                                              await Provider.of<AppProvider>(context, listen: false)
                                                                .removeFromHome(user.id);
                                                            }
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
                                                            bool? answer = await DialogService.dialogBox(
                                                              context: context,
                                                              title: 'Invite to Home?',
                                                              body: Text(
                                                                '${user.name} will have full access to your recipes, menu, and grocery list if they accept the invite.',
                                                                style: InfoBoxTextStyle.body,
                                                              ),
                                                              actions: [
                                                                InfoBoxButton(
                                                                  action: () {
                                                                    Navigator.of(context).pop(false);
                                                                  },
                                                                  text: 'Cancel',
                                                                  isPrimary: true,
                                                                ),
                                                                InfoBoxButton(
                                                                  action: () {
                                                                    Navigator.of(context).pop(true);
                                                                  },
                                                                  text: 'Confirm',
                                                                  isPrimary: true,
                                                                ),
                                                              ],
                                                            );
                                                            bool checkForNullAnswer = answer ?? false;
                                                            if (checkForNullAnswer) {
                                                              await Provider.of<AppProvider>(context, listen: false)
                                                                .inviteToHome(user.id);
                                                            }
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
                          onPressed: () async {
                            bool? answer = await DialogService.dialogBox(
                              context: context,
                              title: 'Report ${user.name}?',
                              actions: [
                                InfoBoxButton(
                                  action: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  text: 'Cancel',
                                  isPrimary: true,
                                ),
                                InfoBoxButton(
                                  action: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  text: 'Confirm',
                                  isPrimary: false,
                                ),
                              ],
                            );
                            bool checkForNullAnswer = answer ?? false;
                            if (checkForNullAnswer) {
                              await Provider.of<AppProvider>(context, listen: false).reportUser(user.id);
                            }
                          },
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
      ),
    );
  }
}
