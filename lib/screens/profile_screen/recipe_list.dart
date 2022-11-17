import 'package:flutter/material.dart';
import 'package:spork/components/spork_spinner.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/profile_screen/recipe_card_profile.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

class RecipesList extends StatelessWidget {
  const RecipesList({required this.query, Key? key}) : super(key: key);
  final String query;

  @override
  Widget build(BuildContext context) {
    bool checkIngredients(Recipe recipe) {
      bool value = false;
      for (String ingredient in recipe.ingredients) {
        if (ingredient.toLowerCase().contains(query.toLowerCase())) {
          value = true;
        }
      }
      return value;
    }

    return StreamBuilder<List<Recipe>>(
      stream: Provider.of<AppProvider>(context, listen: false).recipeStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data;
          List<RecipeCardProfile> main = [];
          List<RecipeCardProfile> side = [];
          List<RecipeCardProfile> dessert = [];
          bool display = false;

          for (var recipe in recipes!) {
            if (recipe.name.toLowerCase().contains(query.toLowerCase())) {
              display = true;
            } else if (recipe.className.toLowerCase().contains(query.toLowerCase())) {
              display = true;
            } else if (checkIngredients(recipe)) {
              display = true;
            } else {
              display = false;
            }

            if (display) {
              if (recipe.className == 'Dessert') {
                dessert.add(RecipeCardProfile(recipe));
              } else if (recipe.className == 'Side') {
                side.add(RecipeCardProfile(recipe));
              } else {
                main.add(RecipeCardProfile(recipe));
              }
            }
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                if (recipes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Recipes you save from the Discover page or recipes you create using the recipes button will appear here.',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: CustomFontSize.secondary,
                          color: CustomColors.grey3
                      ),
                    ),
                  ),
                if (main.isNotEmpty)
                  GridView.count(
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 15,
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
                  GridView.count(
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                      top: main.isEmpty ? 15 : 0,
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
                  GridView.count(
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                      top: main.isEmpty ? 15 : 0,
                    ),
                    children: dessert,
                  ),
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
