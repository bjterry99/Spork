import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/components/search_bar.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/grocery_screen/grocery_list.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/theme.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({required this.buttonOn, required this.buttonOff, required this.isInputVisible, required this.toggleInputOff, required this.controller, Key? key}) : super(key: key);
  final Function buttonOn;
  final Function buttonOff;
  final bool isInputVisible;
  final Function toggleInputOff;
  final TextEditingController controller;

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool isFabVisible = true;
  String query = '';
  bool isInputVisible = false;
  bool canSave = false;
  TextEditingController controller = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible) {
        widget.buttonOn();
        widget.toggleInputOff();
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
    widget.toggleInputOff();
    setState(() {
      isInputVisible = false;
      canSave = false;
    });
    if (controller.text != '') {
      await Provider.of<AppProvider>(context, listen: false).addGroceryItem(controller.text);
    }
    controller.clear();
    searchController.clear();
  }

  void search(String value) {
    setState(() {
      query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: isFabVisible
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton(
                  elevation: 1,
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
                        child: SearchBar(
                          text: "I'm looking for...",
                          search: search,
                          controller: searchController,
                        )
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
                    widget.toggleInputOff();
                  },
                  onPanDown: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (not) {
                      if (not.direction == ScrollDirection.forward) {
                        widget.buttonOn();
                      } else if (not.direction == ScrollDirection.reverse) {
                        widget.buttonOff();
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
            if (widget.isInputVisible)
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38, spreadRadius: 0, blurRadius: 1),
                  ],
                ),
                child: Material(
                  color: CustomColors.white,
                  elevation: 1,
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
                            controller: widget.controller,
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
              ),
          ],
        ),
      ),
    );
  }
}
