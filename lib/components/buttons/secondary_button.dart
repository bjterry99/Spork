import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {required this.text,
        required this.action,
        this.icon,
        Key? key})
      : super(key: key);
  final String text;
  final Function action;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: CustomColors.secondary,
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await action();
      },
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CustomColors.primary, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: icon == null
              ? Text(
            text.toUpperCase(),
            style: const TextStyle(
                color: CustomColors.primary,
                fontSize: CustomFontSize.primary,
                fontWeight: FontWeight.w500),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(
                width: 5,
              ),
              Text(
                text.toUpperCase(),
                style: const TextStyle(
                    color: CustomColors.primary,
                    fontSize: CustomFontSize.primary,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}
