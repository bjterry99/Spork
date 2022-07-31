import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class Instructions extends StatelessWidget {
  const Instructions(this.list, {Key? key}) : super(key: key);

  final List list;

  @override
  Widget build(BuildContext context) {
    List<Widget> createList() {
      List<Widget> items = [];
      int number;
      String text;

      for (var x = 0; x < list.length; x++) {
        number = x + 1;
        text = list[x];

        items.add(Text('$number. $text', style: const TextStyle(fontSize: CustomFontSize.primary, color: CustomColors.black)));
        items.add(const SizedBox(height: 5));
      }

      return items;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: createList(),
    );
  }
}