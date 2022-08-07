import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/screens/profile_screen/menu_list.dart';
import 'package:spork/screens/profile_screen/profile_header.dart';
import 'package:spork/screens/profile_screen/profile_search_bar.dart';
import 'package:spork/screens/profile_screen/recipe_list.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFabVisible = true;
  String query = '';
  bool isOnRecipe = true;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((isVisible) {
      if (!isVisible) {
        setState(() {
          isFabVisible = true;
        });
      } else {
        setState(() {
          isFabVisible = false;
        });
      }
    });
  }

  void search(String text) {
    setState(() {
      query = text;
    });
  }

  void change() {
    setState(() {
      isOnRecipe = !isOnRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRecipe(),
                      ),
                    );
                  },
                ),
              )
            : null,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 0,
                flexibleSpace: ProfileHeader(change: change, isOnRecipe: isOnRecipe,),
                floating: true,
                toolbarHeight: 170,
                snap: false,
                backgroundColor: Colors.transparent,
              ),
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: Delegate(search),
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
              child: PageTransitionSwitcher(
                  reverse: isOnRecipe,
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  child: isOnRecipe ? RecipesList(query: query) : MenuList(query: query,)),
            ),
          ),
        ),
      ),
    );
  }
}