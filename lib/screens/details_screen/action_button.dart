import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsActionButton extends StatelessWidget {
  const DetailsActionButton({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    Widget actionButton(bool canEdit) {
      return FabCircularMenu(
          fabColor: CustomColors.secondary,
          fabCloseColor: CustomColors.primary,
          ringColor: Colors.transparent,
          fabElevation: 3,
          ringDiameter: 375,
          fabCloseIcon: const Icon(Icons.close, color: CustomColors.white,),
          fabOpenIcon: const Icon(Icons.menu, color: CustomColors.white,),
          animationDuration: const Duration(milliseconds: 300),
          children: <Widget>[
            if (recipe.creatorId != user.id)
              GestureDetector(
                onTap: () async {
                  bool? answer = await DialogService.dialogBox(
                    context: context,
                    title: 'Report Recipe?',
                    actions: [
                      InfoBoxButton(
                        action: () {
                          Navigator.of(context).pop(false);
                        },
                        text: 'Cancel',
                        isPrimary: true,
                      ),
                      InfoBoxButton(
                        action: () {
                          Navigator.of(context).pop(true);
                        },
                        text: 'Confirm',
                        isPrimary: false,
                      ),
                    ],
                  );
                  bool checkForNullAnswer = answer ?? false;
                  if (checkForNullAnswer) await Provider.of<AppProvider>(context, listen: false).reportRecipe(recipe.id);
                },
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: CustomColors.secondary,
                  child: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Icon(Icons.report_gmailerrorred_rounded, color: CustomColors.white, size: 20,),
                  ),
                ),
              ),
            if (recipe.creatorId != user.id)
              StreamBuilder<QuerySnapshot>(
                stream: Provider.of<AppProvider>(context, listen: false).savedRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final recipeItems = snapshot.data;
                    bool saved = recipeItems!.docs.map((e) => e.id).toList().contains(recipe.id);

                    return GestureDetector(
                      onTap: () async {
                        if (saved) {
                          await Provider.of<AppProvider>(context, listen: false).unsaveRecipe(recipe);
                        } else {
                          await Provider.of<AppProvider>(context, listen: false).saveRecipe(recipe.id);
                        }
                      },
                      child: Material(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: CustomColors.secondary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant_menu_rounded, color: CustomColors.white, size: 20,),
                              Text(saved ? 'unsave' : 'save', style: const TextStyle(color: CustomColors.white, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Material(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: CustomColors.secondary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.restaurant_menu_rounded, color: CustomColors.white, size: 20,),
                            Text('unsave', style: TextStyle(color: CustomColors.white, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            StreamBuilder<List<Recipe>>(
              stream: Provider.of<AppProvider>(context, listen: false).menuStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final menuItems = snapshot.data;
                  List<String> ids = [];

                  for (var item in menuItems!) {
                    ids.add(item.id.toString());
                  }
                  bool onMenu = ids.contains(recipe.id);

                  return GestureDetector(
                    onTap: () async {
                      if (onMenu) {
                        await Provider.of<AppProvider>(context, listen: false).removeFromMenu(recipe.id);
                      } else {
                        await Provider.of<AppProvider>(context, listen: false).addToMenu(recipe);
                      }
                    },
                    child: Material(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: CustomColors.secondary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book_rounded, color: CustomColors.white, size: 20,),
                            Text(onMenu ? 'remove' : 'add', style: const TextStyle(color: CustomColors.white, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Material(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: CustomColors.secondary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.menu_book_rounded, color: CustomColors.white, size: 20,),
                          Text('add', style: TextStyle(color: CustomColors.white, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            if (canEdit)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CreateRecipe(
                      recipe: recipe,
                    ),
                  ));
                },
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: CustomColors.secondary,
                  child: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Icon(Icons.edit, color: CustomColors.white, size: 20,),
                  ),
                ),
              ),
          ]);
    }

    return FutureBuilder<bool>(
      future: Provider.of<AppProvider>(context, listen: false).canEdit(recipe),
      builder: (builder, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            bool canEdit = snapshot.data ?? false;

            return actionButton(canEdit);
          } else {
            return actionButton(false);
          }
        }
        return actionButton(false);
      },
    );
  }
}
