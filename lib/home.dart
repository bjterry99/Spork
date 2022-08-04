import 'package:flutter/material.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:spork/provider.dart';
import 'screens/grocery_screen/grocery_screen.dart';
import 'screens/menu_screen/menu_screen.dart';
import 'screens/recipes_screen/recipes_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final PageController controller = PageController(initialPage: 0);

  final List<Widget> _children = [
    const RecipesScreen(),
    const GroceryScreen(),
    const MenuScreen(),
  ];

  void onTappedBar(int index) {
    controller.animateToPage(
      index,
      duration: kThemeAnimationDuration,
      curve: Curves.linear,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _changePage(int index) async {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
        body: SafeArea(
          child: PageView(
            controller: controller,
            onPageChanged: _changePage,
            children: _children,
          ),
        ),
        bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 1.5),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BottomNavigationBar(
                elevation: 1,
                onTap: onTappedBar,
                currentIndex: _currentIndex,
                selectedItemColor: CustomColors.white,
                backgroundColor: CustomColors.primary,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_rounded),
                    label: 'Recipes',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_rounded),
                    label: 'Grocery',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_rounded),
                    label: 'Menu',
                  ),
                ],
              ),
            )));
  }
}