import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/buttons/custom_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({required this.myHome, Key? key}) : super(key: key);
  final MyHome myHome;

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  late String homeName;
  late String currentName;

  @override
  void initState() {
    homeName = widget.myHome.name;
    currentName = widget.myHome.name;
    super.initState();
  }

  void editHome() async {
    FocusScope.of(context).unfocus();
    await Provider.of<AppProvider>(context, listen: false).editHomeName(widget.myHome.id, homeName);
    setState(() {
      currentName = homeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

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
            'Home',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary, color: CustomColors.white),
          ),
          actions: [
            if (widget.myHome.creatorId == user.id)
              Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.delete_outline,
                      color: CustomColors.white,
                      size: 25,
                    ),
                  )),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          elevation: 3,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.myHome.creatorId == user.id
                    ? Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: widget.myHome.name,
                              style: const TextStyle(
                                  color: CustomColors.black, fontWeight: FontWeight.w500, fontSize: CustomFontSize.big),
                              textCapitalization: TextCapitalization.words,
                              cursorColor: CustomColors.primary,
                              onChanged: (String? newValue) {
                                setState(() {
                                  homeName = newValue!;
                                });
                              },
                              decoration: const InputDecoration(
                                icon: Icon(
                                  Icons.home_outlined,
                                  size: 25,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.grey3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.grey3),
                                ),
                                hintText: "New Home name...",
                              ),
                            ),
                          ),
                          if (currentName != homeName)
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: CustomButton(
                                  content: Icon(Icons.edit, color: homeName != '' ? CustomColors.white : CustomColors.grey4,),
                                  action: editHome,
                                  isActive: homeName != '',
                                  verticalPadding: 10,
                                  horizontalPadding: 10),
                            ),
                        ],
                      )
                    : Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 25,
                          color: CustomColors.grey4,
                        ),
                        const SizedBox(width: 10,),
                        Text(
                            widget.myHome.name,
                            style: const TextStyle(
                              fontSize: CustomFontSize.big,
                              color: CustomColors.grey4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
