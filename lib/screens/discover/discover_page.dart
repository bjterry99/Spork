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

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await Provider.of<AppProvider>(context, listen: false).searchRecipes(_pageSize, controller.text.toLowerCase(), pageKey);
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

  @override
  void dispose() {
    controller.dispose();
    _pagingController.dispose();
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
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0,
              flexibleSpace: DiscoverHeader(change: change, isOnFollow: isOnFollow,),
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
                    child: DiscoverList(
                      pagingController: _pagingController,
                    )
                  ),
                ),),
          ),
        ),
      ),
    );
  }
}
