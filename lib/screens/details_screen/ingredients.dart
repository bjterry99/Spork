import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class Ingredients extends StatelessWidget {
  const Ingredients(this.list, this.amounts, {Key? key}) : super(key: key);
  final List<String> list;
  final List<String> amounts;

  @override
  Widget build(BuildContext context) {
    List<Widget> createList() {
      List<Widget> items = [];
      List<Widget> measures = [];
      String text;
      String amount;

      for (var x = 0; x < list.length; x++) {
        text = list[x];
        amount = amounts[x];

        items.add(SizedBox(
            height: 24,
            child: Center(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: CustomFontSize.primary,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.grey4)),
            )));
        measures.add(SizedBox(
          height: 24,
          child: Center(
            child: Text(amount,
                style: const TextStyle(
                    fontSize: CustomFontSize.secondary,
                    fontWeight: FontWeight.w300,
                    color: CustomColors.grey4)),
          ),
        ));
      }

      Column ingredients = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      );

      Column measurements = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: measures,
      );

      List<Widget> everything = [
        measurements,
        const SizedBox(
          width: 15,
        ),
        ingredients
      ];

      return everything;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: createList(),
      ),
    );
  }
}
