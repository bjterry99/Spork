import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/screens/grocery_screen/grocery_card.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({required this.query, Key? key}) : super(key: key);
  final String query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Grocery>>(
      stream: Provider.of<AppProvider>(context, listen: false).groceryStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data;
          List<GroceryCard> marked = [];
          List<GroceryCard> unmarked = [];
          bool display = false;

          for (var item in items!) {
            String recipeName = '';
            if (item.recipeId != '') {
              recipeName = item.recipeName.toString().toLowerCase();
            }

            if (item.name.toString().toLowerCase().contains(query)) {
              display = true;
            } else if (item.recipeId != '') {
              if (recipeName.contains(query)) {
                display = true;
              }
            } else {
              display = false;
            }

            if (display) {
              if (item.mark) {
                marked.add(GroceryCard(item));
              } else {
                unmarked.add(GroceryCard(item));
              }
            }
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    top: unmarked.isEmpty ? 15 : 0,
                  ),
                  children: unmarked,
                ),
                if (marked.isNotEmpty && unmarked.isNotEmpty)
                  const Divider(
                    height: 30,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                    color: CustomColors.grey3,
                  ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    top: marked.isEmpty ? 15 : 0,
                  ),
                  children: marked,
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: SpinKitRing(
              color: CustomColors.primary,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}