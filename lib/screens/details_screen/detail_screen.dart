import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/screens/details_screen/ingredients.dart';
import 'package:spork/screens/details_screen/instructions.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.recipe, Key? key}) : super(key: key);
  final QueryDocumentSnapshot recipe;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFabVisible = true;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    String name = widget.recipe['name'];
    String className = widget.recipe['class'];
    String cookTime = widget.recipe['cookTime'];
    String prepTime = widget.recipe['prepTime'];
    List<dynamic> ingredients = widget.recipe['ingredients'];
    List<dynamic> amounts = widget.recipe['ingredient_amounts'];
    List<dynamic> instructions = widget.recipe['instructions'];

    String getTotalTime(String cookTime, String prepTime) {
      int hours = int.parse(cookTime.substring(
          0, cookTime.indexOf(':')));
      int minutes = int.parse(cookTime.replaceRange(0, hours > 9 ? 3 : 2, ''));
      Duration cook =  Duration(hours: hours, minutes: minutes);

      hours = int.parse(prepTime.substring(
          0, prepTime.indexOf(':')));
      minutes = int.parse(prepTime.replaceRange(0, hours > 9 ? 3 : 2, ''));
      Duration prep =  Duration(hours: hours, minutes: minutes);

      Duration totalTime = prep + cook;

      String durationString = totalTime.toString();
      String hoursString = durationString.substring(
          0, durationString.indexOf(':'));
      durationString = durationString.replaceRange(0, int.parse(hoursString) > 9 ? 3 : 2, '');
      String minutesString = durationString.substring(
          0, durationString.indexOf(':'));

      return hoursString + ':' + minutesString;
    }

    Icon getIcon() {
      if (className == 'Side') {
        return const Icon(
          Icons.bakery_dining_outlined,
          color: CustomColors.grey4,
          size: 30,
        );
      } else if (className == 'Dessert') {
        return const Icon(
          Icons.icecream_outlined,
          color: CustomColors.grey4,
          size: 30,
        );
      } else {
        return const Icon(
          Icons.dinner_dining_outlined,
          color: CustomColors.grey4,
          size: 30,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRecipe(recipe: widget.recipe,),
                      ),);
                  },
                  child: const Icon(
                    Icons.edit,
                    color: CustomColors.white,
                    size: 25,
                  ),
                )
              ],
            ),
          ),
        ],
        leading: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Platform.isAndroid
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_back_ios_rounded,
                  size: 25,
                )),
          ],
        ),
        systemOverlayStyle: Platform.isIOS ? SystemUiOverlayStyle.light :
        const SystemUiOverlayStyle(
          statusBarColor: CustomColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        toolbarHeight: 120,
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              className == 'Dessert' ? className : '$className Dish',
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.primary,
                  color: CustomColors.white),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Total Time: ${getTotalTime(cookTime, prepTime)}",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.primary,
                  color: CustomColors.white),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Prep Time: $prepTime",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary,
                  color: CustomColors.white),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Cook Time: $cookTime",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary,
                  color: CustomColors.white),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        elevation: 6,
      ),
      floatingActionButton: isFabVisible
          ? StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data?.docs;
            List<String> ids = [];

            for (var item in menuItems!) {
              ids.add(item.id.toString());
            }
            bool onMenu = ids.contains(widget.recipe.id);

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                backgroundColor: CustomColors.primary,
                child: Icon(onMenu ? Icons.remove_rounded : Icons.add_rounded, color: CustomColors.white,),
                onPressed: onMenu ? () async {
                  await Provider.of<AppProvider>(context, listen: false).removeFromMenu(widget.recipe);
                } : () async {
            await Provider.of<AppProvider>(context, listen: false).addToMenu(widget.recipe);
            }
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                backgroundColor: CustomColors.primary,
                child: const Icon(Icons.add_rounded, color: CustomColors.white,),
                onPressed: (){},
              ),
            );
          }
        },
      ) : null,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (not) {
          if (not.direction == ScrollDirection.forward) {
            setState(() {
              isFabVisible = true;
            });
          } else if (not.direction == ScrollDirection.reverse) {
            setState(() {
              isFabVisible = false;
            });
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 5, top: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getIcon(),
                    const SizedBox(width: 10,),
                    Flexible(
                      child: Text(
                        name,
                        softWrap: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: CustomFontSize.large,
                            color: CustomColors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionPanelList(
                  elevation: 0,
                  animationDuration: const Duration(milliseconds: 300),
                  children: [
                    ExpansionPanel(
                      backgroundColor: Colors.transparent,
                      headerBuilder: (context, isExpanded) {
                        return Card(
                          elevation: 3,
                          color: CustomColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: ListTile(
                            title: Row(
                              children: const [
                                Icon(
                                  Icons.egg_outlined,
                                  color: CustomColors.grey4,
                                  size: 30,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    color: CustomColors.grey4,
                                    fontSize: CustomFontSize.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      body: ListTile(
                        title: Ingredients(ingredients, amounts),
                      ),
                      isExpanded: _expanded,
                      canTapOnHeader: true,
                    ),
                  ],
                  dividerColor: Colors.grey,
                  expansionCallback: (panelIndex, isExpanded) {
                    _expanded = !_expanded;
                    setState(() {});
                  },
                ),
              ),
              Column(
                children: [
                  const Divider(
                    height: 20,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 10,
                      right: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'LibreBodoni',
                                ),
                              ),
                            ),
                            Instructions(instructions),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}