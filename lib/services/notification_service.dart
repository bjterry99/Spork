import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class NotificationService {
  static GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void notify(String message) {
    final snackBar = SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: CustomColors.grey4,
      elevation: 6,
      content: Text(message,
      style: const TextStyle(color: CustomColors.white, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),),
      duration: const Duration(seconds: 2),
    );

    if (key.currentState != null) {
      key.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}