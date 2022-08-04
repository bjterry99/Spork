import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({
    required this.text,
    required this.action,
    Key? key,
  }) : super(key: key);
  final String text;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await action();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text.toLowerCase(),
          style: const TextStyle(
              fontSize: CustomFontSize.secondary,
              color: CustomColors.grey3,
          fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
