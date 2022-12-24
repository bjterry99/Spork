import 'package:flutter/material.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/spork_spinner.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/grocery_screen/grocery_card.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({required this.query, required this.save, required this.clearList, Key? key}) : super(key: key);
  final String query;
  final Function save;
  final Function clearList;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Grocery>>(
      stream: Provider.of<AppProvider>(context, listen: false).groceryStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data;
          List<GroceryCard> marked = [];
          List<GroceryCard> unmarked = [];
          bool display = false;

          for (var item in items!) {
            String recipeName = '';
            if (item.recipeId != '') {
              recipeName = item.recipeName.toString().toLowerCase();
            }

            if (item.name.toString().toLowerCase().contains(query)) {
              display = true;
            } else if (item.creatorName.toLowerCase().contains(query)) {
              display = true;
            } else if (item.recipeId != '') {
              if (recipeName.contains(query)) {
                display = true;
              }
            } else {
              display = false;
            }

            if (display) {
              if (item.mark) {
                marked.add(GroceryCard(item));
              } else {
                unmarked.add(GroceryCard(item));
              }
            }
          }

          if (marked.isEmpty && unmarked.isEmpty && query != '') {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Looks like that item isn't added",
                      style: TextStyle(
                        fontSize: CustomFontSize.primary,
                        fontWeight: FontWeight.w400,
                        color: CustomColors.grey4,
                      ),
                    ),
                  ),
                  MyTextButton(text: 'add now', action: () async {
                    save();
                  })
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                    child: Text(
                      'Add items to your grocery list using the grocery cart button or by by adding recipes to your menu.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: CustomFontSize.secondary,
                        color: CustomColors.grey3
                      ),
                    ),
                  ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    top: unmarked.isEmpty ? 15 : 0,
                  ),
                  children: unmarked,
                ),
                if (marked.isNotEmpty && unmarked.isNotEmpty)
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    top: marked.isEmpty ? 15 : 0,
                  ),
                  children: marked,
                ),
                if (marked.isNotEmpty || unmarked.isNotEmpty)
                  MyTextButton(text: 'clear list', action: () async {
                    clearList();
                  })
              ],
            ),
          );
        } else {
          return const SporkSpinner();
        }
      },
    );
  }
}
