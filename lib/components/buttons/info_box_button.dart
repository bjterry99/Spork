import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class InfoBoxButton extends StatelessWidget {
  const InfoBoxButton({required this.action, required this.text, required this.isPrimary, Key? key})
      : super(key: key);
  final Function action;
  final String text;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 15,
        ),
        InkWell(
          onTap: () async => await action(),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7.5),
            child: Text(
              text.toUpperCase(),
              style: isPrimary ? InfoBoxTextStyle.buttonPrimary : InfoBoxTextStyle.buttonRed,
            ),
          ),
        ),
      ],
    );
  }
}
