import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/grocery_screen/grocery_header.dart';
import 'package:spork/screens/grocery_screen/grocery_list.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/screens/grocery_screen/grocery_search_bar.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/theme.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen(
      {required this.buttonOn,
      required this.buttonOff,
      required this.isInputVisible,
      required this.toggleInputOff,
      required this.controller,
      required this.myFocusNode,
      Key? key})
      : super(key: key);
  final Function buttonOn;
  final Function buttonOff;
  final bool isInputVisible;
  final Function toggleInputOff;
  final TextEditingController controller;
  final FocusNode myFocusNode;

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String query = '';
  bool canSave = false;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible) {
        widget.buttonOn();
        widget.toggleInputOff();
        if (mounted) {
          setState(() {
            widget.controller.clear();
            canSave = false;
          });
        }
      } else {
        widget.buttonOff();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search(String value) {
    setState(() {
      query = value;
    });
  }

  void clear() {
    FocusScope.of(context).unfocus();
    controller.clear();
    setState(() {
      query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context, listen: false).user;

    void saveItem() async {
      widget.toggleInputOff();
      setState(() {
        canSave = false;
        query = '';
      });
      if (widget.controller.text != '') {
        Grocery grocery = Grocery(
            id: '',
            name: widget.controller.text,
            mark: false,
            createDate: DateTime.now(),
            creatorId: user.id,
            homeId: user.homeId,
            creatorName: user.name);
        await Provider.of<AppProvider>(context, listen: false).addGroceryItem(grocery);
      }
      widget.controller.clear();
      controller.clear();
    }

    Future<void> saveSearchItem() async {
      widget.toggleInputOff();
      setState(() {
        canSave = false;
        query = '';
      });
      if (controller.text != '') {
        Grocery grocery = Grocery(
            id: '',
            name: controller.text,
            mark: false,
            creatorId: user.id,
            createDate: DateTime.now(),
            homeId: user.homeId,
            creatorName: user.name);
        await Provider.of<AppProvider>(context, listen: false).addGroceryItem(grocery);
      }
      widget.controller.clear();
      controller.clear();
    }

    void clearGrocery() async {
      bool? answer = await DialogService.dialogBox(
        context: context,
        title: 'Clear Grocery List?',
        body: const Text('This cannot be undone.', style: InfoBoxTextStyle.body),
        actions: [
          InfoBoxButton(
            action: () {
              Navigator.of(context).pop(false);
            },
            text: 'Cancel',
            isPrimary: true,
          ),
          InfoBoxButton(
            action: () {
              Navigator.of(context).pop(true);
            },
            text: 'Confirm',
            isPrimary: true,
          ),
        ],
      );
      bool checkForNullAnswer = answer ?? false;
      if (checkForNullAnswer) {
        await Provider.of<AppProvider>(context, listen: false).deleteAllGroceryItem();
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    const SliverAppBar(
                      elevation: 0,
                      flexibleSpace: GroceryHeader(),
                      floating: true,
                      toolbarHeight: 63,
                      snap: false,
                      backgroundColor: Colors.transparent,
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: DelegateGrocery(search, controller, clear),
                    ),
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (Platform.isAndroid) {
                        FocusScope.of(context).unfocus();
                        widget.toggleInputOff();
                      }
                    },
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (not) {
                        if (not.direction == ScrollDirection.forward) {
                          widget.buttonOn();
                          if (Platform.isIOS) {
                            FocusScope.of(context).unfocus();
                            widget.toggleInputOff();
                          }
                        } else if (not.direction == ScrollDirection.reverse) {
                          widget.buttonOff();
                        }

                        return true;
                      },
                      child: GroceryList(
                        query: query,
                        save: saveSearchItem,
                        clearList: clearGrocery,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isInputVisible)
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 3),
                  ],
                ),
                child: Material(
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
                            focusNode: widget.myFocusNode,
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
                            child: MyTextButton(
                                text: 'Save',
                                action: () {
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
