import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class NotificationService {
  static GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void notify(String message) {
    final snackBar = SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Row(
        children: [
          Material(
            color: CustomColors.grey4,
            elevation: 3,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: CustomColors.white,
                      shape: BoxShape.circle,
                    ),
                    height: 5,
                    width: 5,
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    message,
                    style: const TextStyle(
                      color: CustomColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: CustomFontSize.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );

    if (key.currentState != null) {
      key.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}
