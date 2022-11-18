import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/buttons/custom_button.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/sign_in/sign_in.dart';
import 'package:spork/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.user, Key? key}) : super(key: key);
  final AppUser user;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String newName;
  late String newUserName;
  late String newPic;

  @override
  void initState() {
    newName = widget.user.name;
    newUserName = widget.user.userName;
    newPic = widget.user.photoUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool validate() {
      if (newName != widget.user.name) return true;
      if (newUserName != widget.user.userName) return true;
      if (newPic != widget.user.photoUrl) return true;
      return false;
    }

    void clearGrocery() async {
      bool? answer = await DialogService.dialogBox(
        context: context,
        title: 'Clear Grocery List?',
        body: const Text('This cannot be undone.', style: InfoBoxTextStyle.body),
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
        await Provider.of<AppProvider>(context, listen: false).deleteAllGroceryItem();
      }
    }

    void signOut() async {
      bool? answer = await DialogService.dialogBox(
        context: context,
        title: 'Logout?',
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
        Provider.of<AppProvider>(context, listen: false).signOut();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignIn()), (Route<dynamic> route) => false);
      }
    }

    void edit() async {
      if (Platform.isAndroid) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      AppUser appUser = AppUser(
          id: widget.user.id,
          name: newName,
          userName: newUserName,
          phone: widget.user.phone,
          photoUrl: newPic,
          followers: widget.user.followers,
          homeId: widget.user.homeId,
          queryName: newName.toLowerCase());
      bool edit = await Provider.of<AppProvider>(context, listen: false).editProfile(appUser);
      if (edit) {
        Navigator.pop(context);
      }
    }

    void choosePicture() async {
      String string64 = await Provider.of<AppProvider>(context, listen: false).choosePicture();
      setState(() {
        if (string64 != '') {
          newPic = string64;
        }
      });
    }

    return GestureDetector(
      onTap: () {
        if (Platform.isAndroid) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: Platform.isIOS
              ? SystemUiOverlayStyle.light
              : const SystemUiOverlayStyle(
                  statusBarColor: CustomColors.primary,
                  statusBarIconBrightness: Brightness.light,
                ),
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary, color: CustomColors.white),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          elevation: 3,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: CustomFontSize.big,
                      color: CustomColors.grey4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 5),
                            child: Uri.parse(newPic).isAbsolute || newPic == ''
                                ? ProfileImage(newPic, 85, 40)
                                : CircleAvatar(
                                    radius: 45,
                                    backgroundImage: Image.memory(base64Decode(newPic)).image,
                                  ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: widget.user.name,
                                  style: const TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: CustomFontSize.big),
                                  textCapitalization: TextCapitalization.words,
                                  cursorColor: CustomColors.primary,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      newName = newValue!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: CustomColors.grey3),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: CustomColors.grey3),
                                    ),
                                    hintText: "New name...",
                                  ),
                                ),
                                TextFormField(
                                  initialValue: widget.user.userName,
                                  style: const TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary),
                                  textCapitalization: TextCapitalization.words,
                                  cursorColor: CustomColors.primary,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      newUserName = newValue!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: CustomColors.grey3),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: CustomColors.grey3),
                                    ),
                                    hintText: "New username...",
                                    prefixText: '@',
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          MyTextButton(text: 'New Image', action: choosePicture),
                          const SizedBox(
                            width: 15,
                          ),
                          CustomButton(
                              content: Text(
                                'SAVE',
                                style: TextStyle(
                                    color: validate() ? CustomColors.white : CustomColors.grey4,
                                    fontSize: CustomFontSize.secondary,
                                    fontWeight: FontWeight.w500),
                              ),
                              action: edit,
                              width: MediaQuery.of(context).size.width / 1.76,
                              height: 35,
                              isActive: validate(),
                              verticalPadding: 0,
                              horizontalPadding: 5),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: CustomColors.grey3,
                      ),
                      InkWell(
                        onTap: clearGrocery,
                        splashColor: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete_sweep_outlined,
                                color: CustomColors.grey4,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Clear Grocery List',
                                style: TextStyle(
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: CustomColors.grey3,
                      ),
                      InkWell(
                        onTap: signOut,
                        splashColor: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout_outlined,
                                color: CustomColors.grey4,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: CustomColors.grey3,
                      ),
                      InkWell(
                        onTap: () async {
                          bool? answer = await DialogService.dialogBox(
                            context: context,
                            title: 'Delete Account?',
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
                            answer = await DialogService.dialogBox(
                                context: context,
                                title: 'Are you sure?',
                                body: const Text(
                                  'This action is irreversible.',
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
                                    text: 'Delete',
                                    isPrimary: false,
                                  ),
                                ]);
                            checkForNullAnswer = answer ?? false;
                            if (checkForNullAnswer) {
                              Provider.of<AppProvider>(context, listen: false).deleteUser();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const SignIn()),
                                  (Route<dynamic> route) => false);
                            }
                          }
                        },
                        splashColor: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete_forever_outlined,
                                color: CustomColors.grey4,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
