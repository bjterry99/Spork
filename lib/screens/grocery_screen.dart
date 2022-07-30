import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/components/grocery_cards.dart';
import 'package:spork/components/my_text_button.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

final _firestore = FirebaseFirestore.instance;

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool isFabVisible = true;
  String query = '';
  bool isInputVisible = false;
  bool canSave = false;
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible) {
        setState(() {
          isInputVisible = false;
          isFabVisible = true;
          controller.clear();
          canSave = false;
        });
      } else {
        setState(() {
          isFabVisible = false;
        });
      }
    });
  }

  void saveItem() async {
    setState(() {
      isInputVisible = false;
      canSave = false;
    });
    if (controller.text != '') {
      var ref = _firestore.collection('grocery').doc();
      await ref.set({
        "id": ref.id,
        "name": controller.text,
        "recipeItem": false,
        "mark": false,
      });
    }
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: isFabVisible
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton(
                  backgroundColor: CustomColors.primary,
                  child: const Icon(
                    Icons.add_rounded,
                    color: CustomColors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isInputVisible = true;
                    });
                  },
                ),
              )
            : null,
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      elevation: 0,
                      flexibleSpace: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                                  setState(() {
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
                    setState(() {
                      isInputVisible = false;
                    });
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
                    child: GroceryList(
                      query: query,
                    ),
                  ),
                ),
              ),
            ),
            if (isInputVisible)
              Material(
                color: CustomColors.white,
                elevation: 3,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          autofocus: true,
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'add item...',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                          ),
                          style: const TextStyle(
                            fontSize: CustomFontSize.primary,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                canSave = true;
                              });
                            } else {
                              setState(() {
                                canSave = false;
                              });
                            }
                          },
                          onEditingComplete: () {
                            saveItem();
                          },
                        ),
                      ),
                      if (canSave)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: MyTextButton(text: 'Save', action: (){
                            saveItem();
                          }),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
