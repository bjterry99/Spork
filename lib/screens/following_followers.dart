import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/user_card.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';

class FollowingFollowers extends StatefulWidget {
  const FollowingFollowers({required this.title, required this.user, Key? key}) : super(key: key);
  final String title;
  final AppUser user;

  @override
  State<FollowingFollowers> createState() => _FollowingFollowersState();
}

class _FollowingFollowersState extends State<FollowingFollowers> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Platform.isIOS
            ? null
            : const SystemUiOverlayStyle(
          statusBarColor: CustomColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary, color: CustomColors.white),
        ),
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
              StreamBuilder<List<AppUser>>(
                stream: widget.title=='Following' ? Provider.of<AppProvider>(context, listen: false).followingUsers(widget.user.id) : Provider.of<AppProvider>(context, listen: false).followersUsers(widget.user),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data;
                    if (items != null) {
                      List<Widget> listItems = [];

                      for (var item in items) {
                        listItems.add(UserCard(item));
                      }

                      return ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: listItems,
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
