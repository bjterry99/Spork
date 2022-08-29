import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/details_screen/detail_screen.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeCardExplore extends StatelessWidget {
  const RecipeCardExplore(this.recipe, {Key? key}) : super(key: key);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    double imgWidth = MediaQuery.of(context).size.width / 2.2;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: GestureDetector(
        onTap: () {
          if (Platform.isIOS) {
            Navigator.of(context).push(SwipeablePageRoute(
                builder: (BuildContext context) => DetailScreen(recipe: recipe), canOnlySwipeFromEdge: true));
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => DetailScreen(recipe: recipe),
            ));
          }
        },
        child: Material(
          elevation: 3,
          color: CustomColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              recipe.photoUrl != ''
                  ? CachedNetworkImage(
                      imageUrl: recipe.photoUrl,
                      imageBuilder: (context, imageProvider) => SizedBox(
                        height: imgWidth,
                        width: imgWidth,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                          child: Image(
                            image: imageProvider,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        height: imgWidth,
                        width: imgWidth,
                        decoration: const BoxDecoration(
                            color: CustomColors.grey2,
                            borderRadius:
                                BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: CustomColors.grey4,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: imgWidth,
                        width: imgWidth,
                        decoration: const BoxDecoration(
                            color: CustomColors.grey2,
                            borderRadius:
                                BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: CustomColors.grey4,
                        ),
                      ),
                    )
                  : Container(
                      height: imgWidth,
                      width: imgWidth,
                      decoration: const BoxDecoration(
                          color: CustomColors.grey2,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: CustomColors.grey4,
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: Text(
                  recipe.name,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: CustomColors.black, fontSize: CustomFontSize.primary),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await Provider.of<AppProvider>(context, listen: false).reportRecipe(recipe.id);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.report_gmailerrorred_rounded,
                          color: CustomColors.secondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<QuerySnapshot>(
                      stream: Provider.of<AppProvider>(context, listen: false).savedRecipes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final recipeItems = snapshot.data;
                          bool saved = recipeItems!.docs.map((e) => e.id).toList().contains(recipe.id);

                          return MyTextButton(
                            text: saved ? 'unsave' : 'save',
                            icon: Icons.restaurant_menu_rounded,
                            action: saved
                                ? () async {
                                    await Provider.of<AppProvider>(context, listen: false).unsaveRecipe(recipe);
                                  }
                                : () async {
                                    await Provider.of<AppProvider>(context, listen: false).saveRecipe(recipe.id);
                                  },
                          );
                        } else {
                          return MyTextButton(
                            text: 'save',
                            action: () {},
                            icon: Icons.restaurant_menu_rounded,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
