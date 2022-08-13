import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spork/components/buttons/custom_button.dart';
import 'package:spork/theme.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({required this.isOnFollow, required this.change, Key? key}) : super(key: key);
  final Function change;
  final bool isOnFollow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.white,
      elevation: 0,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: Platform.isAndroid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: Platform.isAndroid ? 10 : 0,),
                child: Text(
                  isOnFollow ? 'Following' : 'Explore',
                  style: const TextStyle(
                      color: CustomColors.grey4,
                      fontSize: CustomFontSize.big,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.group, color: isOnFollow ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: !isOnFollow),
                    CustomButton(
                        horizontalPadding: 10,
                        verticalPadding: 0,
                        height: 35,
                        width: 120,
                        content: Icon(Icons.public, color: !isOnFollow ? CustomColors.grey4 : CustomColors.white,),
                        action: () {
                          change();
                        },
                        isActive: isOnFollow),
                  ],
                ),
              )
            ],
          ),
        ),
      ),);
  }
}
