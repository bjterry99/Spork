import 'package:flutter/material.dart';
import 'package:spork/components/search_bar.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';

class DelegateDetails extends SliverPersistentHeaderDelegate {
  final Recipe recipe;

  DelegateDetails(this.recipe);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Icon getIcon() {
      if (recipe.className == 'Side') {
        return const Icon(
          Icons.bakery_dining_outlined,
          color: CustomColors.grey4,
          size: 30,
        );
      } else if (recipe.className == 'Dessert') {
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

    return Align(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 20, right: 20, bottom: 5, top: 15),
        child: Column(
          children: [
            Text(
              recipe.className == 'Dessert' ? recipe.className : '${recipe.className} Dish',
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.primary,
                  color: CustomColors.grey4),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Total Time: ${getTotalTime(recipe.cookTime, recipe.prepTime)}",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.primary,
                  color: CustomColors.grey4),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Prep Time: ${recipe.prepTime}",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary,
                  color: CustomColors.grey4),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              "Cook Time: ${recipe.cookTime}",
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary,
                  color: CustomColors.grey4),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getIcon(),
                const SizedBox(width: 10,),
                Flexible(
                  child: Text(
                    recipe.name,
                    softWrap: true,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: CustomFontSize.large,
                        color: CustomColors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 95;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}