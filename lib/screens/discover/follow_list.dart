import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/components/user_card.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/discover/recipe_card_explore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:spork/theme.dart';

class FollowList extends StatelessWidget {
  const FollowList({required this.pagingController, required this.pagingControllerUsers, required this.isOnRecipes, Key? key}) : super(key: key);
  final PagingController<int, Recipe> pagingController;
  final PagingController<int, AppUser> pagingControllerUsers;
  final bool isOnRecipes;

  @override
  Widget build(BuildContext context) {
    return isOnRecipes ? PagedGridView<int, Recipe>(
      pagingController: pagingController,
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
    ) : PagedListView<int, AppUser>(
      pagingController: pagingControllerUsers,
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