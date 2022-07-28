import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({required this.text, required this.action, Key? key,}) : super(key: key);
  final String text;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: CustomFontSize.secondary),),
      onPressed: () async {
        await action();
      },
    );
  }
}