import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/user_profile_page/user_header.dart';
import 'package:spork/screens/user_profile_page/user_recipe_list.dart';
import 'package:spork/screens/user_profile_page/user_search_bar.dart';
import 'package:spork/theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({required this.user, Key? key}) : super(key: key);
  final AppUser user;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String query = '';
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search(String text) {
    setState(() {
      query = text;
    });
  }

  void clearSearch() {
    FocusScope.of(context).unfocus();
    controller.clear();
    setState(() {
      query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CustomColors.grey4),
        backgroundColor: CustomColors.white,
        systemOverlayStyle: Platform.isIOS
            ? null
            : const SystemUiOverlayStyle(
                statusBarColor: CustomColors.white,
                statusBarIconBrightness: Brightness.dark,
              ),
        title: RichText(
          softWrap: false,
          overflow: TextOverflow.fade,
          text: TextSpan(
            text: widget.user.name,
            style: const TextStyle(
              color: CustomColors.grey4,
              fontWeight: FontWeight.w600,
              fontSize: CustomFontSize.primary
            ),
            children: <TextSpan>[
              TextSpan(text: ' @${widget.user.userName}', style: const TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        elevation: 3,
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0,
              flexibleSpace: UserProfileHeader(
                user: widget.user,
              ),
              floating: true,
              toolbarHeight: 80,
              snap: false,
              automaticallyImplyLeading: false,
              backgroundColor: CustomColors.white,
              systemOverlayStyle: Platform.isAndroid
                  ? const SystemUiOverlayStyle(
                      statusBarColor: CustomColors.white,
                      statusBarIconBrightness: Brightness.dark,
                    )
                  : null,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: UserDelegateProfile(search, controller, clearSearch),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () {
              if (Platform.isAndroid) {
                FocusScope.of(context).unfocus();
              }
            },
            child: NotificationListener<UserScrollNotification>(
              onNotification: (not) {
                if (not.direction == ScrollDirection.forward) {
                  if (Platform.isIOS) {
                    FocusScope.of(context).unfocus();
                  }
                }

                return true;
              },
              child: UserRecipesList(
                query: query,
                user: widget.user,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
