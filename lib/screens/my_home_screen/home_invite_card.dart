import 'package:flutter/material.dart';
import 'package:spork/components/buttons/ghost_button.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/spork_spinner.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class InviteCard extends StatelessWidget {
  const InviteCard(this.invite, {Key? key}) : super(key: key);
  final HomeInvite invite;

  @override
  Widget build(BuildContext context) {
    double spacing = MediaQuery.of(context).size.width / 15;

    return FutureBuilder<AppUser?>(
      future: Provider.of<AppProvider>(context, listen: false)
          .fetchUser(invite.inviterId),
      builder: (builder, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            AppUser? appUser = snapshot.data;

            if (appUser != null) {
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
                        ProfileImage(appUser.photoUrl, 80, 40),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.home_outlined,
                                  color: CustomColors.grey4,
                                ),
                                const SizedBox(width: 5,),
                                FutureBuilder<MyHome?>(
                                  future: Provider.of<AppProvider>(context, listen: false)
                                      .fetchHome(invite.homeId),
                                  builder: (builder, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        MyHome? myHome = snapshot.data;
                                        if (myHome != null) {
                                          return Text(
                                            myHome.name,
                                            style: const TextStyle(
                                                color: CustomColors.grey4, fontSize: CustomFontSize.primary, fontWeight: FontWeight.w500),
                                          );
                                        } else {
                                          return const Text(
                                            'home-name',
                                            style: TextStyle(
                                                color: CustomColors.grey4, fontSize: CustomFontSize.primary, fontWeight: FontWeight.w500),
                                          );
                                        }
                                      }
                                    }
                                    return const SizedBox();
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width/1.6,
                                child: Text(
                                  appUser.name,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: const TextStyle(
                                      color: CustomColors.grey4, fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 24,),
                                MyTextButton(text: 'accept', action: () async {
                                  bool? answer = await DialogService.dialogBox(
                                    context: context,
                                    title: 'Join Home?',
                                    body: const Text(
                                      'All household members will have full access to your recipes, menu, and grocery list.',
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
                                    Provider.of<AppProvider>(context, listen: false)
                                      .acceptHomeInvite(invite);
                                  }
                                }),
                                SizedBox(width: spacing,),
                                GhostButton(text: 'reject', action: (){
                                  Provider.of<AppProvider>(context, listen: false)
                                      .removeInviteToHome(invite.id);
                                }),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        }
        return const SporkSpinner();
      },
    );
  }
}
