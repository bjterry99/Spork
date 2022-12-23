import 'package:flutter/material.dart';
import 'package:spork/components/recipe_card_explore.dart';
import 'package:spork/components/spork_spinner.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

class UserRecipesList extends StatelessWidget {
  const UserRecipesList({required this.query, required this.user, Key? key}) : super(key: key);
  final String query;
  final AppUser user;

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
      stream: Provider.of<AppProvider>(context, listen: false).userRecipeStream(user),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data;
          List<RecipeCardExplore> main = [];
          List<RecipeCardExplore> side = [];
          List<RecipeCardExplore> dessert = [];
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
                dessert.add(RecipeCardExplore(recipe));
              } else if (recipe.className == 'Side') {
                side.add(RecipeCardExplore(recipe));
              } else {
                main.add(RecipeCardExplore(recipe));
              }
            }
          }

          dessert.sort((a, b) => a.recipe.queryName.compareTo(b.recipe.queryName));
          side.sort((a, b) => a.recipe.queryName.compareTo(b.recipe.queryName));
          main.sort((a, b) => a.recipe.queryName.compareTo(b.recipe.queryName));

          return SingleChildScrollView(
            child: Column(
              children: [
                if (recipes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: Text(
                      '${user.name} has not created any recipes.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: CustomFontSize.secondary,
                          color: CustomColors.grey4
                      ),
                    ),
                  ),
                if (main.isNotEmpty)
                  GridView.count(
                    childAspectRatio: 0.55,
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
                    childAspectRatio: 0.55,
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
                    childAspectRatio: 0.55,
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
