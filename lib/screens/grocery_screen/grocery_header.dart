import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class GroceryHeader extends StatelessWidget {
  const GroceryHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.white,
      borderRadius:
      const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      elevation: 3,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: Platform.isAndroid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: Platform.isAndroid ? 10 : 0,),
                child: const Text(
                  'Grocery List',
                  style: TextStyle(
                      color: CustomColors.grey4,
                      fontSize: CustomFontSize.big,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 3,)
            ],
          ),
        ),
      ),);
  }
}