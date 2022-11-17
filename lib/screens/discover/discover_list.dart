import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spork/components/spork_spinner.dart';
import 'package:spork/components/user_card.dart';
import 'package:spork/models/models.dart';
import 'package:spork/components/recipe_card_explore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:spork/theme.dart';

class DiscoverList extends StatelessWidget {
  const DiscoverList({required this.pagingController, required this.isOnRecipes, required this.pagingControllerUsers, Key? key}) : super(key: key);
  final PagingController<int, Recipe> pagingController;
  final PagingController<int, AppUser> pagingControllerUsers;
  final bool isOnRecipes;

  @override
  Widget build(BuildContext context) {
    return isOnRecipes ? PagedGridView<int, Recipe>(
      pagingController: pagingController,
      keyboardDismissBehavior: Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
      ),
      builderDelegate: PagedChildBuilderDelegate<Recipe>(
        itemBuilder: (context, item, index) => RecipeCardExplore(item),
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
        firstPageProgressIndicatorBuilder: (_) => const SporkSpinner(),
        newPageProgressIndicatorBuilder: (_) => const SporkSpinner(),
      ),
    ) : PagedListView<int, AppUser>(
      pagingController: pagingControllerUsers,
      keyboardDismissBehavior: Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
      builderDelegate: PagedChildBuilderDelegate<AppUser>(
        itemBuilder: (context, item, index) => UserCard(item),
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
        firstPageProgressIndicatorBuilder: (_) => const SporkSpinner(),
        newPageProgressIndicatorBuilder: (_) => const SporkSpinner(),
      ),
    );
  }
}