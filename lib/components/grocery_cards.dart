import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class GroceryCard extends StatelessWidget {
  const GroceryCard(this.item, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot item;

  @override
  Widget build(BuildContext context) {
    void markItem(bool value) async {
      var ref = _firestore.collection('grocery').doc(item.id);
      await ref.update({
        "mark": value,
      });
    }

    void deleteItem() async {
      await _firestore.collection('grocery').doc(item.id).delete();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 5,
      ),
      child: Dismissible(
        onDismissed: (DismissDirection direction) {
          deleteItem();
        },
        key: Key(item.id),
        child: Card(
          elevation: 2,
          color: CustomColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: CustomColors.primary,
                      value: item['mark'],
                      onChanged: (value) {
                        markItem(value!);
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        item['name'],
                        softWrap: true,
                        style: TextStyle(
                          decoration: item['mark'] ? TextDecoration.lineThrough : null,
                            color: CustomColors.black,
                            fontSize: CustomFontSize.primary),
                      ),
                    ),
                  ],
                ),
              ),
              if (item['recipeItem'])
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['amount'],
                      style: const TextStyle(
                          color: CustomColors.grey4,
                          fontSize: CustomFontSize.secondary,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      item['recipeName'],
                      style: const TextStyle(
                          color: CustomColors.grey4,
                          fontSize: CustomFontSize.secondary,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: item['recipeItem'] ? 15 : 5,)
            ],
          ),
        ),
      ),
    );
  }
}

class GroceryList extends StatelessWidget {
  const GroceryList({required this.query, Key? key}) : super(key: key);
  final String query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('grocery').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data?.docs;
          List<GroceryCard> marked = [];
          List<GroceryCard> unmarked = [];
          bool display = false;

          for (var item in items!) {
            String recipeName = '';
            if (item['recipeItem']) {
              recipeName = item['recipeName'].toString().toLowerCase();
            }

            if (item['name'].toString().toLowerCase().contains(query)) {
              display = true;
            } else if (item['recipeItem']) {
              if (recipeName.contains(query)) {
                display = true;
              }
            } else {
              display = false;
            }

            if (display) {
              if (item['mark']) {
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
                  padding: const EdgeInsets.only(
                    right: 8,
                    left: 8,
                    top: 15,
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
                    right: 8,
                    left: 8,
                    top: unmarked.isEmpty ? 15 : 0,
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
