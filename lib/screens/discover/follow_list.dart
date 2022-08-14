import 'package:flutter/material.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/profile_screen/recipe_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FollowList extends StatelessWidget {
  const FollowList({required this.pagingController, Key? key}) : super(key: key);
  final PagingController<int, Recipe> pagingController;

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Recipe>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<Recipe>(
          itemBuilder: (context, item, index) => RecipeCard(item)
      ),
    );
  }
}