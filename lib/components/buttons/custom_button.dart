import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {required this.content, required this.action, required this.isActive, this.height, this.width,
        required this.verticalPadding, required this.horizontalPadding, Key? key})
      : super(key: key);
  final Widget content;
  final Function action;
  final bool isActive;
  final double? height;
  final double? width;
  final double verticalPadding;
  final double horizontalPadding;

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
        child: height != null ? SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
            child: Center(child: content)
          ),
        ) : Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child: content
        ),
      ),
    );
  }
}
