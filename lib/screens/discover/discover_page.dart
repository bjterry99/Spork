import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/discover/discover_header.dart';
import 'package:spork/screens/discover/discover_list.dart';
import 'package:spork/screens/discover/disocover_search_bar.dart';
import 'package:spork/screens/discover/follow_list.dart';
import 'package:spork/theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({required this.buttonOn, required this.buttonOff, Key? key}) : super(key: key);
  final Function buttonOn;
  final Function buttonOff;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController controller = TextEditingController();
  bool isOnFollow = true;
  bool isOnRecipe = true;
  static const _pageSize = 20;
  final PagingController<int, Recipe> _pagingController = PagingController(firstPageKey: 0);
  final PagingController<int, AppUser> _pagingControllerUsers = PagingController(firstPageKey: 0);
  final PagingController<int, Recipe> _pagingController2 = PagingController(firstPageKey: 0);
  final PagingController<int, AppUser> _pagingControllerUsers2 = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _pagingControllerUsers.addPageRequestListener((pageKey) {
      _fetchPageUsers(pageKey);
    });
    _pagingController2.addPageRequestListener((pageKey) {
      _fetchPage2(pageKey);
    });
    _pagingControllerUsers2.addPageRequestListener((pageKey) {
      _fetchPageUsers2(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await Provider.of<AppProvider>(context, listen: false)
          .searchRecipesExplore(_pageSize, controller.text.toLowerCase(), pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchPageUsers(int pageKey) async {
    try {
      final newItems = await Provider.of<AppProvider>(context, listen: false)
          .searchPeopleExplore(_pageSize, controller.text.toLowerCase(), pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerUsers.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingControllerUsers.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingControllerUsers.error = error;
    }
  }

  Future<void> _fetchPage2(int pageKey) async {
    try {
      final newItems = await Provider.of<AppProvider>(context, listen: false)
          .searchRecipesFollow(_pageSize, controller.text.toLowerCase(), pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController2.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController2.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController2.error = error;
    }
  }

  Future<void> _fetchPageUsers2(int pageKey) async {
    try {
      final newItems = await Provider.of<AppProvider>(context, listen: false)
          .searchPeopleFollow(_pageSize, controller.text.toLowerCase(), pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerUsers2.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingControllerUsers2.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingControllerUsers2.error = error;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _pagingController.dispose();
    _pagingControllerUsers.dispose();
    _pagingController2.dispose();
    _pagingControllerUsers2.dispose();
    super.dispose();
  }

  void change() {
    setState(() {
      isOnFollow = !isOnFollow;
    });
  }

  void changeSearch() {
    setState(() {
      isOnRecipe = !isOnRecipe;
    });
  }

  void updateSearch(value) {
    if (value == '') {
      controller.clear();
    }
    _pagingController.refresh();
    _pagingControllerUsers.refresh();
    _pagingController2.refresh();
    _pagingControllerUsers2.refresh();
  }

  @override
  Widget build(BuildContext context) {
    Widget getList() {
      if (controller.text == '') {
        return const SizedBox();
      } else {
        return isOnFollow
            ? FollowList(
                pagingController: _pagingController2,
          isOnRecipes: isOnRecipe,
          pagingControllerUsers: _pagingControllerUsers2,
              )
            : DiscoverList(
                pagingController: _pagingController,
          isOnRecipes: isOnRecipe,
          pagingControllerUsers: _pagingControllerUsers,
              );
      }
    }

    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0,
              flexibleSpace: DiscoverHeader(
                change: change,
                isOnFollow: isOnFollow,
              ),
              floating: true,
              toolbarHeight: 110,
              snap: false,
              backgroundColor: Colors.transparent,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: DelegateDiscover(updateSearch, controller, isOnRecipe, changeSearch),
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
                widget.buttonOn();
              } else if (not.direction == ScrollDirection.reverse) {
                widget.buttonOff();
              }

              return true;
            },
            child: PageTransitionSwitcher(
              reverse: true,
              transitionBuilder: (child, animation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
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
                  child: PageTransitionSwitcher(
                    reverse: isOnFollow,
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: getList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
