import 'package:flutter/material.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/theme.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

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

        items.add(Linkify(
          onOpen: (link) async {
            await Provider.of<AppProvider>(context, listen: false).openUrl(link.url);
          },
          text: '$number. $text',
          style: const TextStyle(fontSize: CustomFontSize.primary, color: CustomColors.black),
          linkStyle: const TextStyle(fontSize: CustomFontSize.primary, color: CustomColors.black,),
        ));
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