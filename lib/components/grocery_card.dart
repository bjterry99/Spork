import 'package:flutter/material.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class GroceryCard extends StatelessWidget {
  const GroceryCard(this.item, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 5,
      ),
      child: Dismissible(
        onDismissed: (DismissDirection direction) async {
          await Provider.of<AppProvider>(context, listen: false).deleteGroceryItem(item.id);
        },
        key: Key(item.id),
        child: Card(
          elevation: 2,
          color: CustomColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: CustomColors.primary,
                      value: item['mark'],
                      onChanged: (value) async {
                        await Provider.of<AppProvider>(context, listen: false).markGroceryItem(value!, item.id);
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        item['name'],
                        softWrap: true,
                        style: TextStyle(
                          decoration: item['mark'] ? TextDecoration.lineThrough : null,
                            color: CustomColors.black,
                            fontSize: CustomFontSize.primary),
                      ),
                    ),
                  ],
                ),
              ),
              if (item['recipeItem'])
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['amount'],
                      style: const TextStyle(
                          color: CustomColors.grey4,
                          fontSize: CustomFontSize.secondary,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      item['recipeName'],
                      style: const TextStyle(
                          color: CustomColors.grey4,
                          fontSize: CustomFontSize.secondary,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: item['recipeItem'] ? 15 : 5,)
            ],
          ),
        ),
      ),
    );
  }
}