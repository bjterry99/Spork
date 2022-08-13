import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/discover/discover_header.dart';
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
              flexibleSpace: DiscoverHeader(change: (){}, isOnFollow: true,),
              floating: true,
              toolbarHeight: 170,
              snap: false,
              backgroundColor: Colors.transparent,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: DelegateDiscover((){}),
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
                child: Container()),
          ),
        ),
      ),
    );
  }
}
