import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/details_screen/detail_screen.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';

class RecipeCardProfile extends StatelessWidget {
  const RecipeCardProfile(this.recipe, {Key? key}) : super(key: key);
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => DetailScreen(recipe: recipe),
          ));
        },
        child: Material(
          elevation: 3,
          color: CustomColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: recipe.id,
                child: recipe.photoUrl != ''
                    ? CachedNetworkImage(
                  imageUrl: recipe.photoUrl,
                  imageBuilder: (context, imageProvider) => SizedBox(
                    height: imgWidth,
                    width: imgWidth,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
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
                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
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
                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
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
                padding: const EdgeInsets.only(right: 5),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: StreamBuilder<List<Recipe>>(
                    stream: Provider.of<AppProvider>(context, listen: false).menuStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final menuItems = snapshot.data;
                        List<String> ids = [];

                        for (var item in menuItems!) {
                          ids.add(item.id.toString());
                        }
                        bool onMenu = ids.contains(recipe.id);

                        return MyTextButton(text: onMenu ? 'remove' : 'add', icon: Icons.menu_book_rounded, action: onMenu ? () async {
                          await Provider.of<AppProvider>(context, listen: false).removeFromMenu(recipe.id);
                        } : () async {
                          await Provider.of<AppProvider>(context, listen: false).addToMenu(recipe);
                        },);
                      } else {
                        return MyTextButton(text: 'add', action: (){}, icon: Icons.menu_book_rounded,);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 5,)
            ],
          ),
        ),
      ),
    );
  }
}
