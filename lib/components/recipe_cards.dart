import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/components/my_text_button.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/detail_screen.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

final _firestore = FirebaseFirestore.instance;

class RecipeCard extends StatelessWidget {
  const RecipeCard(this.recipe, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot recipe;

  @override
  Widget build(BuildContext context) {
    Icon getIcon() {
      if (recipe['class'] == 'Side') {
        return const Icon(
          Icons.bakery_dining_outlined,
          color: CustomColors.grey4,
        );
      } else if (recipe['class'] == 'Dessert') {
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
        left: 10.0,
        right: 10,
        bottom: 5,
      ),
      child: Card(
        elevation: 2,
        color: CustomColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      recipe['name'],
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
                  Navigator.of(context).push(SwipeablePageRoute(
                    builder: (BuildContext context) => DetailScreen(recipe: recipe),
                  ));
                },),
                const SizedBox(width: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('menu').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final menuItems = snapshot.data?.docs;
                      List<String> ids = [];

                      for (var item in menuItems!) {
                        ids.add(item.id.toString());
                      }
                      bool onMenu = ids.contains(recipe.id);

                      return MyTextButton(text: onMenu ? 'remove from menu' : 'add to menu', action: onMenu ? () async {
                        await Provider.of<AppProvider>(context, listen: false).removeFromMenu(recipe);
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

class RecipesList extends StatelessWidget {
  const RecipesList({required this.query, Key? key}) : super(key: key);
  final String query;

  @override
  Widget build(BuildContext context) {
    bool checkIngredients(var recipe) {
      bool value = false;
      for (String ingredient in recipe['ingredients']) {
        if (ingredient.toLowerCase().contains(query.toLowerCase())) {
          value = true;
        }
      }
      return value;
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data?.docs;
          List<RecipeCard> main = [];
          List<RecipeCard> side = [];
          List<RecipeCard> dessert = [];
          bool display = false;

          for (var recipe in recipes!) {
            if (recipe['name'].toString().toLowerCase().contains(query.toLowerCase())) {
              display = true;
            } else if (recipe['class'].toString().toLowerCase().contains(query.toLowerCase())){
              display = true;
            } else if (checkIngredients(recipe)){
              display = true;
            } else {
              display = false;
            }

            if (display) {
              if (recipe['class'] == 'Dessert') {
                dessert.add(RecipeCard(recipe));
              } else if (recipe['class'] == 'Side') {
                side.add(RecipeCard(recipe));
              } else {
                main.add(RecipeCard(recipe));
              }
            }
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                if (main.isNotEmpty)
                  ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 8,
                      left: 8,
                      top: main.isEmpty ? 15 : 0,
                    ),
                  children: main,
                ),
                if (side.isNotEmpty && main.isNotEmpty)
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                if (side.isNotEmpty)
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 8,
                    left: 8,
                    top: side.isEmpty ? 15 : 0,
                  ),
                  children: side,
                ),
                if (dessert.isNotEmpty && (main.isNotEmpty || side.isNotEmpty))
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                if (dessert.isNotEmpty)
                  ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 8,
                    left: 8,
                    top: dessert.isEmpty ? 15 : 0,
                  ),
                  children: dessert,
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: SpinKitRing(
              color: CustomColors.primary,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}

class MenuList extends StatelessWidget {
  const MenuList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('menu').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data?.docs;
          List<RecipeCard> main = [];
          List<RecipeCard> side = [];
          List<RecipeCard> dessert = [];

          for (var recipe in recipes!) {
            if (recipe['class'] == 'Dessert') {
              dessert.add(RecipeCard(recipe));
            } else if (recipe['class'] == 'Side') {
              side.add(RecipeCard(recipe));
            } else {
              main.add(RecipeCard(recipe));
            }
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            child: Column(
              children: [
                if (main.isNotEmpty)
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 8,
                      left: 8,
                      top: main.isEmpty ? 15 : 0,
                    ),
                    children: main,
                  ),
                if (side.isNotEmpty && main.isNotEmpty)
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                if (side.isNotEmpty)
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 8,
                      left: 8,
                      top: side.isEmpty ? 15 : 0,
                    ),
                    children: side,
                  ),
                if (dessert.isNotEmpty && (main.isNotEmpty || side.isNotEmpty))
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                if (dessert.isNotEmpty)
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 8,
                      left: 8,
                      top: dessert.isEmpty ? 15 : 0,
                    ),
                    children: dessert,
                  ),
              ],
            ),
          );
        } else {
          return const Center(
            child: SpinKitRing(
              color: CustomColors.primary,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}