import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {required this.text,
        required this.action,
        required this.isActive,
        this.icon,
        Key? key})
      : super(key: key);
  final String text;
  final Function action;
  final bool isActive;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (isActive) {
          await action();
        }
      },
      child: Material(
        elevation: isActive ? 3 : 0,
        color: isActive ? CustomColors.secondary : CustomColors.grey2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: icon == null
              ? Text(
            text.toUpperCase(),
            style: TextStyle(
                color: isActive ? CustomColors.white : CustomColors.grey4,
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
                style: TextStyle(
                    color: isActive ? CustomColors.white : CustomColors.grey4,
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
