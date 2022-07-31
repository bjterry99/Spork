import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/components/recipe_card.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

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
      stream: Provider.of<AppProvider>(context, listen: false).recipeStream,
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