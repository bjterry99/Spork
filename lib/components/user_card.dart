import 'package:flutter/material.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  const UserCard(this.user, {Key? key}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    AppUser appUser = Provider.of<AppProvider>(context).user;
    MyHome? home = Provider.of<AppProvider>(context).myHome;

    Widget getHomeIcon() {
      if (home != null) {
        if (home.creatorId == appUser.id) {
          if (home.users.contains(user.id)) {
            return IconButton(
              padding: const EdgeInsets.all(5),
              splashRadius: 20,
              splashColor: CustomColors.secondary,
              color: CustomColors.secondary,
              onPressed: () {},
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
              onPressed: () {},
              icon: const Icon(
                Icons.home_outlined,
              ),
            );
          }
        }
      }
      return const SizedBox();
    }

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
                      user.followers.contains(appUser.id)
                          ? IconButton(
                              padding: const EdgeInsets.all(5),
                              splashRadius: 20,
                              splashColor: CustomColors.secondary,
                              color: CustomColors.secondary,
                              onPressed: () {},
                              icon: const Icon(
                                Icons.group_remove,
                              ),
                            )
                          : IconButton(
                              padding: const EdgeInsets.all(5),
                              splashRadius: 20,
                              splashColor: CustomColors.secondary,
                              color: CustomColors.secondary,
                              onPressed: () {},
                              icon: const Icon(
                                Icons.group_add_outlined,
                              ),
                            ),
                      getHomeIcon(),
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
