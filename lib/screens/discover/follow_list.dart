import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/models/models.dart';
import 'package:spork/components/recipe_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:spork/theme.dart';

class FollowList extends StatelessWidget {
  const FollowList({required this.pagingController, Key? key}) : super(key: key);
  final PagingController<int, Recipe> pagingController;

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Recipe>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<Recipe>(
        itemBuilder: (context, item, index) => RecipeCard(item),
        newPageErrorIndicatorBuilder: (_) => const Center(
          child: Text(
            'Error encountered',
            style:
                TextStyle(color: CustomColors.danger, fontWeight: FontWeight.w600, fontSize: CustomFontSize.secondary),
          ),
        ),
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text(
            'No results',
            style:
                TextStyle(color: CustomColors.grey3, fontWeight: FontWeight.w600, fontSize: CustomFontSize.secondary),
          ),
        ),
        firstPageProgressIndicatorBuilder: (_) => const Center(
          child: SpinKitRing(
            color: CustomColors.primary,
            size: 50.0,
          ),
        ),
        newPageProgressIndicatorBuilder: (_) => const Center(
          child: SpinKitRing(
            color: CustomColors.primary,
            size: 50.0,
          ),
        ),
      ),
    );
  }
}
