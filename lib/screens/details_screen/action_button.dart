import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsActionButton extends StatefulWidget {
  const DetailsActionButton({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  State<DetailsActionButton> createState() => _DetailsActionButtonState();
}

class _DetailsActionButtonState extends State<DetailsActionButton> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  bool onMenu = false;
  bool saved = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    Widget actionButton(bool canEdit) {
      return StreamBuilder<List<Recipe>>(
        stream: Provider.of<AppProvider>(context, listen: false).menuStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data;
            List<String> ids = [];
            for (var item in menuItems!) {
              ids.add(item.id.toString());
            }

            onMenu = ids.contains(widget.recipe.id);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: Provider.of<AppProvider>(context, listen: false).savedRecipes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final recipeItems = snapshot.data;
                saved = recipeItems!.docs.map((e) => e.id).toList().contains(widget.recipe.id);
              }

              return FloatingActionBubble(
                items: <Bubble>[
                  if (canEdit)
                    Bubble(
                      title: "Edit",
                      iconColor: CustomColors.white,
                      bubbleColor: CustomColors.primary,
                      icon: Icons.edit,
                      titleStyle: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.white),
                      onPress: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => CreateRecipe(
                            recipe: widget.recipe,
                          ),
                        ));
                      },
                    ),
                  if (widget.recipe.creatorId != user.id)
                    Bubble(
                      title: saved ? 'Unsave' : 'Save',
                      iconColor: CustomColors.white,
                      bubbleColor: CustomColors.primary,
                      icon: Icons.restaurant_menu_rounded,
                      titleStyle: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.white),
                      onPress: () async {
                        if (saved) {
                          await Provider.of<AppProvider>(context, listen: false).unsaveRecipe(widget.recipe);
                        } else {
                          await Provider.of<AppProvider>(context, listen: false).saveRecipe(widget.recipe.id);
                        }
                      },
                    ),
                  Bubble(
                    title: onMenu ? 'Remove' : 'Add',
                    iconColor: CustomColors.white,
                    bubbleColor: CustomColors.primary,
                    icon: Icons.menu_book_rounded,
                    titleStyle: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.white),
                    onPress: () async {
                      if (onMenu) {
                        await Provider.of<AppProvider>(context, listen: false).removeFromMenu(widget.recipe.id);
                      } else {
                        await Provider.of<AppProvider>(context, listen: false).addToMenu(widget.recipe);
                      }
                    },
                  ),
                  if (widget.recipe.creatorId != user.id)
                    Bubble(
                      title: "Report",
                      iconColor: CustomColors.white,
                      bubbleColor: CustomColors.primary,
                      icon: Icons.report_gmailerrorred_rounded,
                      titleStyle: const TextStyle(fontSize: CustomFontSize.secondary, color: CustomColors.white),
                      onPress: () async {
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
                        if (checkForNullAnswer) {
                          await Provider.of<AppProvider>(context, listen: false).reportRecipe(widget.recipe.id);
                        }
                      },
                    ),
                ],
                animation: _animation,
                onPress: () =>
                    _animationController.isCompleted ? _animationController.reverse() : _animationController.forward(),
                iconColor: CustomColors.white,
                iconData: Icons.menu,
                backGroundColor: CustomColors.primary,
              );
            },
          );
        },
      );
    }

    return FutureBuilder<bool>(
      future: Provider.of<AppProvider>(context, listen: false).canEdit(widget.recipe),
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
