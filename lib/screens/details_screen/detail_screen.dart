import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/details_screen/details_title_bar.dart';
import 'package:spork/screens/details_screen/details_header.dart';
import 'package:spork/screens/details_screen/ingredients.dart';
import 'package:spork/screens/details_screen/instructions.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.recipe, Key? key}) : super(key: key);
  final Recipe recipe;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFabVisible = true;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    double imgWidth = MediaQuery.of(context).size.width / 1;
    AppUser user = Provider.of<AppProvider>(context).user;

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

    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0,
              flexibleSpace: DetailsHeader(
                url: widget.recipe.photoUrl
              ),
              floating: true,
              automaticallyImplyLeading: false,
              toolbarHeight: imgWidth,
              snap: false,
              backgroundColor: Colors.transparent,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: DelegateDetails(widget.recipe, MediaQuery.of(context).size.width / 1.285),
            ),
          ];
        },
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          onPanDown: (_) {
            FocusScope.of(context).unfocus();
          },
          child: NotificationListener<UserScrollNotification>(
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
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Time:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              getTotalTime(widget.recipe.cookTime, widget.recipe.prepTime),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Prep Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Cook Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.recipe.prepTime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  widget.recipe.cookTime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                              ],
                            ),
                          ],
                        )
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
                                  borderRadius: BorderRadius.circular(20)),
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
                            title: Ingredients(widget.recipe.ingredients, widget.recipe.ingredientAmounts),
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
                                Instructions(widget.recipe.instructions),
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
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: isFabVisible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: FabCircularMenu(
          fabColor: CustomColors.secondary,
          fabCloseColor: CustomColors.primary,
          ringColor: Colors.transparent,
            fabElevation: 3,
            ringDiameter: 300,
            children: <Widget>[
              if (widget.recipe.creatorId != user.id)
                StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<AppProvider>(context, listen: false).specificRecipe(widget.recipe.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final recipeItems = snapshot.data;
                      bool saved = recipeItems!.docs.isNotEmpty;

                      return GestureDetector(
                        onTap: () async {
                          if (saved) {
                            await Provider.of<AppProvider>(context, listen: false).unsaveRecipe(widget.recipe);
                          } else {
                            await Provider.of<AppProvider>(context, listen: false).saveRecipe(widget.recipe.id);
                          }
                        },
                        child: Material(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: CustomColors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Text(saved ? 'unsave' : 'save'),
                          ),
                        ),
                      );
                    } else {
                      return Material(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: CustomColors.white,
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Text('unsave'),
                        ),
                      );
                    }
                  },
                ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: CustomColors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: CustomColors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: CustomColors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ]
        ),
      )
      // StreamBuilder<List<Recipe>>(
      //   stream: Provider.of<AppProvider>(context, listen: false).menuStream(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       final menuItems = snapshot.data;
      //       List<String> ids = [];
      //
      //       for (var item in menuItems!) {
      //         ids.add(item.id.toString());
      //       }
      //       bool onMenu = ids.contains(widget.recipe.id);
      //
      //       return Padding(
      //         padding: const EdgeInsets.all(15.0),
      //         child: FloatingActionButton(
      //           elevation: 3,
      //           backgroundColor: CustomColors.primary,
      //           child: Icon(onMenu ? Icons.remove_rounded : Icons.add_rounded, color: CustomColors.white,),
      //           onPressed: onMenu ? () async {
      //             await Provider.of<AppProvider>(context, listen: false).removeFromMenu(widget.recipe.id);
      //           } : () async {
      //       await Provider.of<AppProvider>(context, listen: false).addToMenu(widget.recipe);
      //       }
      //         ),
      //       );
      //     } else {
      //       return Padding(
      //         padding: const EdgeInsets.all(15.0),
      //         child: FloatingActionButton(
      //           elevation: 3,
      //           backgroundColor: CustomColors.primary,
      //           child: const Icon(Icons.add_rounded, color: CustomColors.white,),
      //           onPressed: (){},
      //         ),
      //       );
      //     }
      //   },
      // )
    );
  }
}