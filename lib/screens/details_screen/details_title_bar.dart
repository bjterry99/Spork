import 'package:flutter/material.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';

class DelegateDetails extends SliverPersistentHeaderDelegate {
  final Recipe recipe;
  final double textWidth;

  DelegateDetails(this.recipe, this.textWidth);

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

    return Align(
      child: Container(
        color: CustomColors.white,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 20, right: 20, bottom: 10, top: 10),
          child: Row(
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
        ),
      ),
    );
  }

  double _textSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: CustomFontSize.large,
            color: CustomColors.black),), maxLines: 2, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: textWidth);
    return textPainter.size.height;
  }

  @override
  double get maxExtent => _textSize(recipe.name) + 20;

  @override
  double get minExtent => _textSize(recipe.name) + 20;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}