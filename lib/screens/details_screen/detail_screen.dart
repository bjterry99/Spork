import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/screens/details_screen/details_back_bar.dart';
import 'package:spork/screens/details_screen/details_header.dart';
import 'package:spork/screens/details_screen/ingredients.dart';
import 'package:spork/screens/details_screen/instructions.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

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
              delegate: DelegateDetails(widget.recipe),
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
                    padding: const EdgeInsets.all(10.0),
                    child: ExpansionPanelList(
                      elevation: 0,
                      animationDuration: const Duration(milliseconds: 300),
                      children: [
                        ExpansionPanel(
                          backgroundColor: Colors.transparent,
                          headerBuilder: (context, isExpanded) {
                            return Card(
                              elevation: 1,
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
      // appBar: AppBar(
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 15),
      //       child: Column(
      //         children: [
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           GestureDetector(
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => CreateRecipe(recipe: widget.recipe,),
      //                 ),);
      //             },
      //             child: const Icon(
      //               Icons.edit,
      //               color: CustomColors.white,
      //               size: 25,
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //   ],
      //   leading: Column(
      //     children: [
      //       const SizedBox(
      //         height: 10,
      //       ),
      //       GestureDetector(
      //           onTap: () {
      //             Navigator.pop(context);
      //           },
      //           child: Icon(
      //             Platform.isAndroid
      //                 ? Icons.arrow_back_rounded
      //                 : Icons.arrow_back_ios_rounded,
      //             size: 25,
      //           )),
      //     ],
      //   ),
      //   systemOverlayStyle: Platform.isIOS ? SystemUiOverlayStyle.light :
      //   const SystemUiOverlayStyle(
      //     statusBarColor: CustomColors.primary,
      //     statusBarIconBrightness: Brightness.light,
      //   ),
      //   toolbarHeight: 120,
      //   centerTitle: false,
      //   title: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         widget.recipe.className == 'Dessert' ? widget.recipe.className : '${widget.recipe.className} Dish',
      //         style: const TextStyle(
      //             fontWeight: FontWeight.w400,
      //             fontSize: CustomFontSize.primary,
      //             color: CustomColors.white),
      //       ),
      //       const SizedBox(
      //         height: 3,
      //       ),
      //       Text(
      //         "Total Time: ${getTotalTime(widget.recipe.cookTime, widget.recipe.prepTime)}",
      //         style: const TextStyle(
      //             fontWeight: FontWeight.w400,
      //             fontSize: CustomFontSize.primary,
      //             color: CustomColors.white),
      //       ),
      //       const SizedBox(
      //         height: 3,
      //       ),
      //       Text(
      //         "Prep Time: ${widget.recipe.prepTime}",
      //         style: const TextStyle(
      //             fontWeight: FontWeight.w400,
      //             fontSize: CustomFontSize.secondary,
      //             color: CustomColors.white),
      //       ),
      //       const SizedBox(
      //         height: 3,
      //       ),
      //       Text(
      //         "Cook Time: ${widget.recipe.cookTime}",
      //         style: const TextStyle(
      //             fontWeight: FontWeight.w400,
      //             fontSize: CustomFontSize.secondary,
      //             color: CustomColors.white),
      //       ),
      //       const SizedBox(
      //         height: 5,
      //       ),
      //     ],
      //   ),
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(20),
      //     ),
      //   ),
      //   elevation: 1,
      // ),
      floatingActionButton: isFabVisible
          ? StreamBuilder<List<Recipe>>(
        stream: Provider.of<AppProvider>(context, listen: false).menuStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menuItems = snapshot.data;
            List<String> ids = [];

            for (var item in menuItems!) {
              ids.add(item.id.toString());
            }
            bool onMenu = ids.contains(widget.recipe.id);

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                elevation: 3,
                backgroundColor: CustomColors.primary,
                child: Icon(onMenu ? Icons.remove_rounded : Icons.add_rounded, color: CustomColors.white,),
                onPressed: onMenu ? () async {
                  await Provider.of<AppProvider>(context, listen: false).removeFromMenu(widget.recipe.id);
                } : () async {
            await Provider.of<AppProvider>(context, listen: false).addToMenu(widget.recipe);
            }
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                elevation: 3,
                backgroundColor: CustomColors.primary,
                child: const Icon(Icons.add_rounded, color: CustomColors.white,),
                onPressed: (){},
              ),
            );
          }
        },
      ) : null,
    );
  }
}