import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/my_home_screen/home_invite_card.dart';
import 'package:spork/theme.dart';

class NoHome extends StatefulWidget {
  const NoHome({Key? key}) : super(key: key);

  @override
  State<NoHome> createState() => _NoHomeState();
}

class _NoHomeState extends State<NoHome> {
  String homeName = '';

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    Future<void> submit() async {
      MyHome home = MyHome(id: '', name: homeName, creatorId: user.id, users: [user.id]);
      await Provider.of<AppProvider>(context, listen: false).createHome(home);
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
            'Create / Join Home',
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
            keyboardDismissBehavior:
                Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Home',
                    style: TextStyle(
                      fontSize: CustomFontSize.big,
                      color: CustomColors.grey4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextFormField(
                    style: const TextStyle(
                        color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
                    textCapitalization: TextCapitalization.words,
                    cursorColor: CustomColors.primary,
                    onChanged: (String? newValue) {
                      setState(() {
                        homeName = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      icon: Icon(
                        Icons.short_text_rounded,
                        size: 20,
                      ),
                      hintText: "Home name...",
                    ),
                  ),
                  Center(
                    child: PrimaryButton(
                      text: 'Create',
                      action: submit,
                      isActive: homeName != '',
                      icon: Icon(
                        Icons.home_outlined,
                        color: homeName != '' ? CustomColors.white : CustomColors.grey4,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 50,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: CustomColors.grey3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<List<HomeInvite>>(
                    stream: Provider.of<AppProvider>(context, listen: false).inviteStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final items = snapshot.data;
                        List<Widget> listItems = [];

                        for (var item in items!) {
                          listItems.add(InviteCard(item));
                        }

                        if (listItems.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Home Invites',
                                style: TextStyle(
                                  fontSize: CustomFontSize.big,
                                  color: CustomColors.grey4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 15,),
                              ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: listItems,
                              ),
                            ],
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Create and invite household members to your home to share your recipe book and grocery list with them.',
                              style: TextStyle(
                                fontSize: CustomFontSize.secondary,
                                color: CustomColors.grey3,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
