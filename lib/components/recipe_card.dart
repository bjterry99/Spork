import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/details_screen/detail_screen.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard(this.recipe, {Key? key}) : super(key: key);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    Icon getIcon() {
      if (recipe.className == 'Side') {
        return const Icon(
          Icons.bakery_dining_outlined,
          color: CustomColors.grey4,
        );
      } else if (recipe.className == 'Dessert') {
        return const Icon(
          Icons.icecream_outlined,
          color: CustomColors.grey4,
        );
      } else {
        return const Icon(
          Icons.dinner_dining_outlined,
          color: CustomColors.grey4,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
        bottom: 5,
      ),
      child: Card(
        elevation: 1,
        color: CustomColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getIcon(),
                  const SizedBox(width: 15,),
                  Flexible(
                    child: Text(
                      recipe.name,
                      softWrap: true,
                      style: const TextStyle(
                          color: CustomColors.black,
                          fontSize: CustomFontSize.primary),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyTextButton(text: 'View recipe', action: (){
                  if (Platform.isIOS) {
                    Navigator.of(context).push(SwipeablePageRoute(
                      builder: (BuildContext context) => DetailScreen(recipe: recipe),
                      canOnlySwipeFromEdge: true
                    ));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => DetailScreen(recipe: recipe),
                    ));
                  }
                },),
                const SizedBox(width: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<AppProvider>(context, listen: false).specificMenuItem(recipe.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final menuItems = snapshot.data?.docs;
                      List<String> ids = [];

                      for (var item in menuItems!) {
                        ids.add(item.id.toString());
                      }
                      bool onMenu = ids.contains(recipe.id);

                      return MyTextButton(text: onMenu ? 'remove from menu' : 'add to menu', action: onMenu ? () async {
                        await Provider.of<AppProvider>(context, listen: false).removeFromMenu(recipe.id);
                      } : () async {
                        await Provider.of<AppProvider>(context, listen: false).addToMenu(recipe);
                      },);
                    } else {
                      return MyTextButton(text: 'add to menu', action: (){},);
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}