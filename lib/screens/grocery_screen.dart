import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/components/add_grocery_item_popup.dart';
import 'package:spork/components/grocery_cards.dart';
import 'package:spork/theme.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool isFabVisible = true;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: isFabVisible ? Padding(
          padding: const EdgeInsets.all(15.0),
          child: FloatingActionButton(
            backgroundColor: CustomColors.primary,
            child: const Icon(Icons.add_rounded, color: CustomColors.white,),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {

                return const GroceryPopup();
              },
              );
            },
          ),
        ) : null,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Material(
                    color: CustomColors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: TextFormField(
                          onChanged: (value) {
                            setState((){
                              query = value;
                            });
                          },
                          cursorColor: CustomColors.primary,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            icon: Icon(
                              Icons.search_rounded,
                            ),
                            hintText: "I'm looking for...",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                floating: true,
                toolbarHeight: 60,
                snap: true,
                backgroundColor: Colors.transparent,
              ),
            ];
          },
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: NotificationListener<UserScrollNotification>(
              onNotification: (not) {
                if (not.direction == ScrollDirection.forward) {
                  setState(() {
                    isFabVisible = true;
                  });
                } else if (not.direction == ScrollDirection.reverse) {
                  setState(() {
                    isFabVisible = false;
                  });
                }

                return true;
              },
              child: GroceryList(query: query,),
            ),
          ),),),
    );
  }
}