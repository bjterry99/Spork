import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({required this.text, required this.action, this.icon, Key? key,}) : super(key: key);
  final String text;
  final Function action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return TextButton(
        child: Text(text.toUpperCase(), style: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.secondary, fontWeight: FontWeight.w500),),
        onPressed: () async {
          await action();
        },
      );
    } else {
      return InkWell( 
        onTap: () async {
          await action();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: CustomColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text(text.toUpperCase(), style: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.secondary, fontWeight: FontWeight.w500),),
            ],
          ),
        ),
      );
    }
  }
}