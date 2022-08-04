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
    return InkWell(
      splashColor: CustomColors.secondary,
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        if (isActive) {
          await action();
        }
      },
      child: Material(
        elevation: isActive ? 3 : 0,
        color: isActive ? CustomColors.secondary : Colors.transparent,
        shape: isActive ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ) : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CustomColors.grey3, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: icon == null
              ? Text(
                  text.toUpperCase(),
                  style: TextStyle(
                      color: isActive ? CustomColors.white : CustomColors.secondary,
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
                          color: isActive ? CustomColors.white : CustomColors.secondary,
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
