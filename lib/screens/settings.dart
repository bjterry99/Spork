import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/buttons/custom_button.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
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

    void signOut() {
      Provider.of<AppProvider>(context, listen: false).signOut;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignIn()), (Route<dynamic> route) => false);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanDown: (_) {
        FocusScope.of(context).unfocus();
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
                  const SizedBox(height: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ProfileImage(widget.user.photoUrl, 85, 40),
                          ),
                          const SizedBox(width: 15,),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: widget.user.name,
                                  style: const TextStyle(
                                      color: CustomColors.black, fontWeight: FontWeight.w500, fontSize: CustomFontSize.big),
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
                                      color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
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
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          MyTextButton(text: 'New Image', action: (){}),
                          const Spacer(),
                          CustomButton(
                              content: Text(
                                'SAVE',
                                style: TextStyle(
                                    color: validate() ? CustomColors.white : CustomColors.grey4,
                                    fontSize: CustomFontSize.secondary,
                                    fontWeight: FontWeight.w500),
                              ),
                              action: (){},
                              isActive: validate(),
                              verticalPadding: 10,
                              horizontalPadding: 10),
                          const SizedBox(width: 10,)
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
                        onTap: signOut,
                        splashColor: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(
                                  Icons.logout_outlined,
                              color: CustomColors.grey4,),
                              SizedBox(width: 10,),
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
                        onTap: (){},
                        splashColor: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete_forever_outlined,
                                color: CustomColors.grey4,),
                              SizedBox(width: 10,),
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
